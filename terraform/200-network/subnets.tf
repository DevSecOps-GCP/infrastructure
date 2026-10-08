resource "google_compute_subnetwork" "this" {
  for_each = var.subnets

  project                  = local.host_project
  name                     = "${each.key}-${var.region}"
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = each.value.cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = each.value.pods
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = each.value.services
  }

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.1
    metadata             = "EXCLUDE_ALL_METADATA"
  }
}
