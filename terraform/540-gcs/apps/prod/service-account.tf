resource "google_service_account" "backend" {
  project      = local.project
  account_id   = "learnhub-backend"
  display_name = "LearnHub backend (prod cluster)"
}

resource "google_service_account_iam_member" "backend_wi" {
  service_account_id = google_service_account.backend.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.wi_pool}[${var.kubernetes_service_account}]"
}

# Workload Identity has no private key, so the backend signs URLs through the IAM
# signBlob API as itself.
resource "google_service_account_iam_member" "backend_sign" {
  service_account_id = google_service_account.backend.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = google_service_account.backend.member
}

# Create, read and delete objects in the videos bucket only.
resource "google_storage_bucket_iam_member" "backend" {
  bucket = google_storage_bucket.videos.name
  role   = "roles/storage.objectUser"
  member = google_service_account.backend.member
}
