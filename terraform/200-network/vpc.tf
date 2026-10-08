resource "google_compute_network" "this" {
  project                 = local.host_project
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}
