locals {
  pool = google_iam_workload_identity_pool.github.name

  plan_folder_roles = [
    "roles/iam.securityReviewer",
    "roles/viewer",
  ]

  apply_folder_roles = [
    "roles/artifactregistry.admin",
    "roles/certificatemanager.owner",
    "roles/cloudkms.admin",
    "roles/cloudsql.admin",
    "roles/compute.instanceAdmin.v1",
    "roles/compute.loadBalancerAdmin",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/compute.xpnAdmin",
    "roles/container.admin",
    "roles/dns.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/redis.admin",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.projectIamAdmin",
    "roles/servicenetworking.networksAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
  ]
}

# Any branch of the infrastructure repo: read-only plan.
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
  member             = "principalSet://iam.googleapis.com/${local.pool}/attribute.repository_id/${var.infrastructure_repo_id}"
}

resource "google_service_account_iam_member" "tf_apply_wif" {
  service_account_id = google_service_account.tf_apply.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${local.pool}/attribute.apply_repository_id/${var.infrastructure_repo_id}"
}

# Plan reads state without locking (terraform plan -lock=false), so a PR branch can't
# overwrite any stack's state.
resource "google_storage_bucket_iam_member" "tfstate" {
  for_each = {
    plan  = { role = "roles/storage.objectViewer", member = google_service_account.tf_plan.member }
    apply = { role = "roles/storage.objectUser", member = google_service_account.tf_apply.member }
  }

  bucket = google_storage_bucket.tfstate.name
  role   = each.value.role
  member = each.value.member
}

resource "google_folder_iam_member" "tf_plan" {
  for_each = toset(local.plan_folder_roles)

  folder = google_folder.this.name
  role   = each.value
  member = google_service_account.tf_plan.member
}

# Reads Terraform makes when refreshing resources that roles/viewer doesn't cover. The
# Memorystore AUTH string is also stored in state, which tf-plan can already read.
resource "google_organization_iam_custom_role" "tf_plan_refresh" {
  org_id      = var.org_id
  role_id     = "terraformPlanRefresh"
  title       = "Terraform plan refresh"
  description = "Read permissions for Terraform refresh that roles/viewer doesn't include"
  permissions = [
    "redis.instances.getAuthString",
    "storage.buckets.get",
  ]
}

resource "google_folder_iam_member" "tf_plan_refresh" {
  folder = google_folder.this.name
  role   = google_organization_iam_custom_role.tf_plan_refresh.name
  member = google_service_account.tf_plan.member
}

resource "google_folder_iam_member" "tf_apply" {
  for_each = toset(local.apply_folder_roles)

  folder = google_folder.this.name
  role   = each.value
  member = google_service_account.tf_apply.member
}

resource "google_billing_account_iam_member" "tf_apply" {
  billing_account_id = var.billing_account
  role               = "roles/billing.user"
  member             = google_service_account.tf_apply.member
}
