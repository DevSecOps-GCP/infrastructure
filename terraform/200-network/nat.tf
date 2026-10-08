resource "google_compute_router" "this" {
  project = local.host_project
  name    = "${var.network_name}-${local.region}"
  region  = local.region
  network = google_compute_network.this.id
}

# Outbound internet for nodes without external IPs (image pulls, Let's Encrypt, GitHub).
resource "google_compute_router_nat" "this" {
  project                            = local.host_project
  name                               = "${var.network_name}-${local.region}"
  router                             = google_compute_router.this.name
  region                             = local.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
