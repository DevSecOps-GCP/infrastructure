resource "google_project_service" "this" {
  for_each = toset([
    "billingbudgets.googleapis.com",
    "certificatemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "orgpolicy.googleapis.com",
    "redis.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "sts.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = false
}
