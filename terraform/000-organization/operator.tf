# Read-only view of everything in the folder for the human operator: resources, logs,
# metrics and IAM policies, plus bucket settings (roles/viewer lists buckets but can't
# read them). No secret values, no object data, no changes.
resource "google_folder_iam_member" "operator" {
  for_each = toset([
    "roles/iam.securityReviewer",
    "roles/storage.bucketViewer",
    "roles/viewer",
  ])

  folder = google_folder.this.name
  role   = each.value
  member = "user:${var.operator_email}"
}
