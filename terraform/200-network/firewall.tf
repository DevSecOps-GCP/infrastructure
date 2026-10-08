# Inbound is denied by default and logged; allows are explicit and tag-scoped.
# GKE manages its own intra-cluster and load-balancer rules (see shared-vpc-iam.tf).

resource "google_compute_firewall" "deny_all_ingress" {
  project       = local.host_project
  name          = "deny-all-ingress"
  network       = google_compute_network.this.id
  direction     = "INGRESS"
  priority      = 65534
  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }
}

# Prod workloads reach ops services: Vault, metrics and log ingestion.
resource "google_compute_firewall" "allow_prod_to_ops" {
  project       = local.host_project
  name          = "allow-prod-to-ops"
  network       = google_compute_network.this.id
  direction     = "INGRESS"
  source_ranges = [var.subnets.prod.cidr, var.subnets.prod.pods]
  target_tags   = ["gke-ops"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "allow_health_checks" {
  project       = local.host_project
  name          = "allow-health-checks"
  network       = google_compute_network.this.id
  direction     = "INGRESS"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["gke-ops", "gke-prod"]

  allow {
    protocol = "tcp"
  }
}
