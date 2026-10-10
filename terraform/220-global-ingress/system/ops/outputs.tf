output "gateway" {
  value = {
    address_name = google_compute_global_address.gateway.name
    address      = google_compute_global_address.gateway.address
    ssl_policy   = google_compute_ssl_policy.tls12.name
    hostnames    = [for h in var.hostnames : "${h}.${local.internal_domain}"]
  }
}
