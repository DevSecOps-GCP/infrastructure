# Address of the ops Gateway (gke-l7-global-external-managed), referenced by name.
resource "google_compute_global_address" "gateway" {
  project      = local.project
  name         = "ops-gateway"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_compute_ssl_policy" "tls12" {
  project         = local.project
  name            = "ops-gateway-tls12"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "google_dns_record_set" "hosts" {
  for_each = local.records

  project      = local.dns_project
  managed_zone = each.value.zone
  name         = "${each.value.host}.${local.internal_domain}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gateway.address]
}
