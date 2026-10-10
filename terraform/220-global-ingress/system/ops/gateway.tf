# Private address of the ops Gateway (gke-l7-rilb), referenced by name. Shared so the
# HTTP and HTTPS listeners use the same IP.
resource "google_compute_address" "gateway" {
  project      = local.project
  name         = "ops-gateway"
  region       = local.region
  subnetwork   = local.subnet.self_link
  address_type = "INTERNAL"
  purpose      = "SHARED_LOADBALANCER_VIP"
}

resource "google_compute_region_ssl_policy" "tls12" {
  project         = local.project
  name            = "ops-gateway-tls12"
  region          = local.region
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

# Resolvable only inside the VPC (and over the VPN).
resource "google_dns_record_set" "hosts" {
  for_each = var.hostnames

  project      = local.dns_project
  managed_zone = local.internal_zone.name
  name         = "${each.value}.${local.internal_domain}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.gateway.address]
}
