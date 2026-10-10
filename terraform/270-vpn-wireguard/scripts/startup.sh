#!/bin/bash
# WireGuard VPN server bootstrap. Runs at every boot and is idempotent.
# Settings come from instance metadata (wg-*); the server private key is created here
# once and never leaves the VM.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
if ! command -v wg >/dev/null || ! command -v dnsmasq >/dev/null || ! command -v jq >/dev/null; then
  apt-get update -q
  apt-get install -y -q wireguard-tools dnsmasq jq nftables
fi

install -d -m 700 /etc/wireguard
if [ ! -s /etc/wireguard/server.key ]; then
  (umask 077 && wg genkey > /etc/wireguard/server.key)
fi
wg pubkey < /etc/wireguard/server.key > /etc/wireguard/server.pub

# --- helpers shared with the peer watcher -------------------------------------------
cat > /usr/local/lib/wg-metadata.sh <<'EOF'
MD="http://metadata.google.internal/computeMetadata/v1/instance/attributes"
md() { curl -sf -H "Metadata-Flavor: Google" "$MD/$1"; }
EOF

cat > /usr/local/sbin/wg-render <<'EOF'
#!/bin/bash
# Writes /etc/wireguard/wg0.conf from metadata. Optional $1: wg-peers JSON.
set -euo pipefail
. /usr/local/lib/wg-metadata.sh
peers=${1:-$(md wg-peers)}
tmp=$(mktemp /etc/wireguard/.wg0.XXXXXX)
{
  echo "[Interface]"
  echo "Address = $(md wg-tunnel-address)"
  echo "ListenPort = $(md wg-listen-port)"
  echo "PrivateKey = $(cat /etc/wireguard/server.key)"
  echo
  # Only well-formed peers are written; names are reduced to safe characters.
  jq -r '.[]
    | select((.public_key | test("^[A-Za-z0-9+/]{42}[AEIMQUYcgkosw480]=$"))
         and (.address | test("^10\\.99\\.0\\.[0-9]{1,3}/32$")))
    | "[Peer]\n# \(.name | gsub("[^A-Za-z0-9_.-]"; "_"))\nPublicKey = \(.public_key)\nAllowedIPs = \(.address)\n"' <<<"$peers"
} > "$tmp"
chmod 600 "$tmp"
mv "$tmp" /etc/wireguard/wg0.conf
EOF
chmod 755 /usr/local/sbin/wg-render

cat > /usr/local/sbin/wg-peer-watch <<'EOF'
#!/bin/bash
# Applies peer changes from metadata to the running tunnel, without a restart.
set -uo pipefail
. /usr/local/lib/wg-metadata.sh
etag=NONE
while true; do
  if body=$(curl -sf -H "Metadata-Flavor: Google" -D /run/wg-peers.headers \
      "$MD/wg-peers?wait_for_change=true&timeout_sec=300&last_etag=$etag"); then
    new_etag=$(tr -d '\r' < /run/wg-peers.headers | awk -F': ' 'tolower($1)=="etag" {print $2}')
    if [ -n "$new_etag" ] && [ "$new_etag" != "$etag" ]; then
      etag=$new_etag
      /usr/local/sbin/wg-render "$body" && wg syncconf wg0 <(wg-quick strip wg0) \
        && echo "applied peers (etag $etag)"
    fi
  else
    sleep 10
  fi
done
EOF
chmod 755 /usr/local/sbin/wg-peer-watch

# shellcheck source=/dev/null
. /usr/local/lib/wg-metadata.sh
tunnel_address=$(md wg-tunnel-address)
routed_cidr=$(md wg-routed-cidr)
tunnel_cidr=$(python3 -c 'import ipaddress, sys; print(ipaddress.ip_interface(sys.argv[1]).network)' "$tunnel_address")
iface=$(ip -o -4 route show default | awk '{print $5; exit}')

# --- routing: tunnel clients reach only the VPC range, NATed behind this VM ---------
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-wireguard.conf
sysctl -q --system

cat > /etc/nftables.conf <<EOF
#!/usr/sbin/nft -f
flush ruleset

table inet filter {
  chain forward {
    type filter hook forward priority 0; policy drop;
    ct state established,related accept
    iifname "wg0" oifname "$iface" ip daddr $routed_cidr accept
  }
}

table ip nat {
  chain postrouting {
    type nat hook postrouting priority 100;
    oifname "$iface" ip saddr $tunnel_cidr masquerade
  }
}
EOF
systemctl enable -q nftables
nft -f /etc/nftables.conf

# --- tunnel -------------------------------------------------------------------------
/usr/local/sbin/wg-render
systemctl enable -q wg-quick@wg0
if systemctl is-active -q wg-quick@wg0; then
  wg syncconf wg0 <(wg-quick strip wg0)
else
  systemctl start wg-quick@wg0
fi

# --- DNS for clients: answers from the VPC resolver, private zones included ----------
cat > /etc/dnsmasq.d/wireguard.conf <<EOF
interface=wg0
except-interface=lo
bind-dynamic
no-resolv
server=169.254.169.254
EOF
systemctl enable -q dnsmasq
systemctl restart dnsmasq

# --- live peer updates --------------------------------------------------------------
cat > /etc/systemd/system/wg-peer-watch.service <<'EOF'
[Unit]
Description=Apply WireGuard peers from instance metadata
After=wg-quick@wg0.service
Requires=wg-quick@wg0.service

[Service]
ExecStart=/usr/local/sbin/wg-peer-watch
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable -q --now wg-peer-watch

echo "WireGuard server public key: $(cat /etc/wireguard/server.pub)"
