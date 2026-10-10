instance_name  = "wireguard"
zone_suffix    = "a"
machine_type   = "e2-micro"
listen_port    = 51820
tunnel_address = "10.99.0.1/24"
routed_cidr    = "10.10.0.0/16"

peers = [
  { name = "ossama-laptop", public_key = "8pMZf4w40yBIaE9GJ8QJu2Pt/5ntgAmg1rQIWb3LYRs=", address = "10.99.0.2/32" },
]
