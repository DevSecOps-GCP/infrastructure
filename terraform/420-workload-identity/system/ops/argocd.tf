resource "google_service_account" "argocd" {
  project      = local.project
  account_id   = "argocd"
  display_name = "ArgoCD (ops cluster)"
}

# The application controller syncs and the server shows live state; both talk to the
# clusters ArgoCD manages.
resource "google_service_account_iam_member" "argocd_wi" {
  for_each = toset(["argocd-application-controller", "argocd-server"])

  service_account_id = google_service_account.argocd.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.wi_pool}[argocd/${each.value}]"
}

# Enough to reach the prod control plane through its DNS endpoint. What ArgoCD may do
# inside the cluster comes from Kubernetes RBAC (410-k8s-bootstrap/apps/prod).
resource "google_project_iam_member" "argocd_prod" {
  project = local.prod_project
  role    = "roles/container.clusterViewer"
  member  = google_service_account.argocd.member
}
