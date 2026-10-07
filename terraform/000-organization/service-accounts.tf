locals {
  pool = google_iam_workload_identity_pool.github.name

  plan_folder_roles = [
    "roles/iam.securityReviewer",
    "roles/viewer",
  ]

  apply_folder_roles = [
    "roles/artifactregistry.admin",
    "roles/cloudkms.admin",
    "roles/compute.xpnAdmin",
    "roles/container.admin",
    "roles/dns.admin",
    "roles/editor",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin",
  ]
}

# Pull requests: read-only plan.
resource "google_service_account" "tf_plan" {
  account_id   = "tf-plan"
  display_name = "Terraform plan"

  depends_on = [google_project_service.this]
}

# main branch only, via the protected "production" GitHub environment.
resource "google_service_account" "tf_apply" {
  account_id   = "tf-apply"
  display_name = "Terraform apply"

  depends_on = [google_project_service.this]
}

resource "google_service_account_iam_member" "tf_plan_wif" {
  service_account_id = google_service_account.tf_plan.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${local.pool}/attribute.repository/${var.infrastructure_repo}"
}

resource "google_service_account_iam_member" "tf_apply_wif" {
  service_account_id = google_service_account.tf_apply.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${local.pool}/subject/repo:${var.infrastructure_repo}:environment:production"
}

resource "google_storage_bucket_iam_member" "tfstate" {
  for_each = {
    plan  = google_service_account.tf_plan.member
    apply = google_service_account.tf_apply.member
  }

  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectUser"
  member = each.value
}

resource "google_folder_iam_member" "tf_plan" {
  for_each = toset(local.plan_folder_roles)

  folder = google_folder.this.name
  role   = each.value
  member = google_service_account.tf_plan.member
}

resource "google_folder_iam_member" "tf_apply" {
  for_each = toset(local.apply_folder_roles)

  folder = google_folder.this.name
  role   = each.value
  member = google_service_account.tf_apply.member
}

resource "google_organization_iam_member" "tf_plan" {
  org_id = var.org_id
  role   = "roles/orgpolicy.policyViewer"
  member = google_service_account.tf_plan.member
}

resource "google_organization_iam_member" "tf_apply" {
  org_id = var.org_id
  role   = "roles/orgpolicy.policyAdmin"
  member = google_service_account.tf_apply.member
}

resource "google_billing_account_iam_member" "tf_apply" {
  billing_account_id = var.billing_account
  role               = "roles/billing.user"
  member             = google_service_account.tf_apply.member
}
