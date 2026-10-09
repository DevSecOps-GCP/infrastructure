# kubectl / port-forward through the DNS endpoint. The email stays out of the repository.
resource "google_project_iam_member" "operator" {
  project = local.project
  role    = "roles/container.developer"
  member  = "user:${var.operator_email}"
}
