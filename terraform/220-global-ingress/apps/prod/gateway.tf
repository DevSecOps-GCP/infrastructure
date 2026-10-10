# Address of the prod Gateway (gke-l7-global-external-managed), referenced by name from
# the Gateway manifest so the public IP and DNS outlive the load balancer.
resource "google_compute_global_address" "gateway" {
  project      = local.project
  name         = "app-gateway"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_dns_record_set" "app" {
  project      = local.dns_project
  managed_zone = local.public_zone
  name         = "${local.fqdn}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gateway.address]
}

resource "google_compute_ssl_policy" "tls12" {
  project         = local.project
  name            = "app-gateway-tls12"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}
