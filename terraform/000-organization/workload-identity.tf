resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github"
  display_name              = "GitHub Actions"

  depends_on = [google_project_service.this]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions"
  attribute_condition                = "assertion.repository_owner_id == '${var.github_org_id}'"

  attribute_mapping = {
    "google.subject"          = "assertion.sub"
    "attribute.repository_id" = "assertion.repository_id"
    # Set only for jobs in the "production" environment running on main, so GCP itself
    # enforces "apply from main", not just the GitHub environment settings.
    "attribute.apply_repository_id" = "assertion.sub.endsWith(':environment:production') && assertion.ref == 'refs/heads/main' ? assertion.repository_id : 'none'"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
