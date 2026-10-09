output "cluster" {
  value = {
    project      = local.project
    name         = google_container_cluster.this.name
    location     = google_container_cluster.this.location
    dns_endpoint = google_container_cluster.this.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint
  }
}

output "workload_identity_pool" {
  value = google_container_cluster.this.workload_identity_config[0].workload_pool
}

output "node_service_account" {
  value = google_service_account.nodes.email
}
