resource "google_dns_managed_zone" "internal" {
  project     = local.host_project
  name        = replace(var.internal_domain, ".", "-")
  dns_name    = "${var.internal_domain}."
  description = "Internal names, resolvable only inside the VPC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.this.id
    }
  }
}
