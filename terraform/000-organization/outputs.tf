output "org_id" {
  value = var.org_id
}

output "billing_account" {
  value = var.billing_account
}

output "folder_id" {
  value = google_folder.this.folder_id
}

output "state_bucket" {
  value = google_storage_bucket.tfstate.name
}

output "workload_identity_pool" {
  value = google_iam_workload_identity_pool.github.name
}

output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}

output "tf_plan_service_account" {
  value = google_service_account.tf_plan.email
}

output "tf_apply_service_account" {
  value = google_service_account.tf_apply.email
}
