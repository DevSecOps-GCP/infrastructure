# Names the prod Gateway manifests refer to.
output "gateway" {
  value = {
    hostname        = local.fqdn
    address_name    = google_compute_global_address.gateway.name
    address         = google_compute_global_address.gateway.address
    certificate_map = google_certificate_manager_certificate_map.app.name
    ssl_policy      = google_compute_ssl_policy.tls12.name
    security_policy = google_compute_security_policy.edge.name
  }
}
