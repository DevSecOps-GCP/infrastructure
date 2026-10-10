resource "google_compute_subnetwork" "proxy_only" {
  project       = local.host_project
  name          = "proxy-only-${var.region}"
  region        = var.region
  network       = google_compute_network.this.id
  ip_cidr_range = var.proxy_only_range
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}
