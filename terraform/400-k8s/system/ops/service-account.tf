resource "google_service_account" "nodes" {
  project      = local.project
  account_id   = "gke-${var.cluster_name}-nodes"
  display_name = "GKE ${var.cluster_name} nodes"
}

resource "google_project_iam_member" "nodes" {
  project = local.project
  role    = "roles/container.defaultNodeServiceAccount"
  member  = google_service_account.nodes.member
}

resource "google_artifact_registry_repository_iam_member" "nodes_pull" {
  project    = local.registry.project
  location   = local.registry.location
  repository = local.registry.name
  role       = "roles/artifactregistry.reader"
  member     = google_service_account.nodes.member
}
