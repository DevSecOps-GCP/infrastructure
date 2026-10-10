output "vpn" {
  value = {
    endpoint = "vpn.${local.domain}:${var.listen_port}"
    ip       = google_compute_address.vpn.address
    instance = google_compute_instance.wireguard.name
    zone     = local.zone
    peers    = [for p in var.peers : "${p.name} ${p.address}"]
  }
}
