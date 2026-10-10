output "bucket" {
  value = google_storage_bucket.videos.name
}

output "backend_service_account" {
  description = "Annotate the backend Kubernetes service account with iam.gke.io/gcp-service-account"
  value       = google_service_account.backend.email
}
