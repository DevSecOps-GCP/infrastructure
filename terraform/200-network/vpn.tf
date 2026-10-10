resource "google_compute_subnetwork" "vpn" {
  project                  = local.host_project
  name                     = "vpn-${var.region}"
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.vpn_range
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.1
    metadata             = "EXCLUDE_ALL_METADATA"
  }
}

# WireGuard answers only packets authenticated with a peer key; unauthenticated
# traffic gets no response, so the port reveals nothing to scanners.
resource "google_compute_firewall" "allow_wireguard" {
  project       = local.host_project
  name          = "allow-wireguard"
  network       = google_compute_network.this.id
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["wireguard"]

  allow {
    protocol = "udp"
    ports    = ["51820"]
  }
}

# Administrative SSH only through Identity-Aware Proxy (IAM + OS Login).
resource "google_compute_firewall" "allow_iap_ssh" {
  project       = local.host_project
  name          = "allow-iap-ssh"
  network       = google_compute_network.this.id
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["wireguard"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }
}
