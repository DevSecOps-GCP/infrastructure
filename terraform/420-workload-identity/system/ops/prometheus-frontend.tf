# Query proxy for Google Managed Prometheus: Grafana on ops reads prod metrics through it,
# keylessly. Read-only access to the prod project's metrics.
resource "google_service_account" "prometheus_frontend" {
  project      = local.project
  account_id   = "prometheus-frontend"
  display_name = "Managed Prometheus query frontend (ops cluster)"
}

resource "google_service_account_iam_member" "prometheus_frontend_wi" {
  service_account_id = google_service_account.prometheus_frontend.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.wi_pool}[monitoring/prometheus-frontend]"
}

resource "google_project_iam_member" "prometheus_frontend_prod" {
  project = local.prod_project
  role    = "roles/monitoring.viewer"
  member  = google_service_account.prometheus_frontend.member
}
