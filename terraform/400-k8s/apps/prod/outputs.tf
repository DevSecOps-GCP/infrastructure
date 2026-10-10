output "cluster" {
  value = {
    project      = local.project
    name         = google_container_cluster.this.name
    location     = google_container_cluster.this.location
    dns_endpoint = google_container_cluster.this.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint
  }
}

output "workload_identity_pool" {
  value = "${local.project}.svc.id.goog"
}

output "oidc_issuer" {
  description = "Issuer of this cluster's service account tokens (Vault JWT auth)"
  value       = "https://container.googleapis.com/v1/projects/${local.project}/locations/${local.region}/clusters/${var.cluster_name}"
}

output "node_service_account" {
  value = google_service_account.nodes.email
}
