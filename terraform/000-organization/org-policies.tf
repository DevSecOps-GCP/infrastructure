resource "google_org_policy_policy" "enforced" {
  for_each = toset([
    "compute.requireOsLogin",
    "compute.requireShieldedVm",
    "compute.skipDefaultNetworkCreation",
    "iam.automaticIamGrantsForDefaultServiceAccounts",
    "iam.disableServiceAccountKeyCreation",
    "iam.disableServiceAccountKeyUpload",
    "sql.restrictPublicIp",
    "storage.publicAccessPrevention",
    "storage.uniformBucketLevelAccess",
  ])

  name   = "${google_folder.this.name}/policies/${each.value}"
  parent = google_folder.this.name

  spec {
    rules {
      enforce = "TRUE"
    }
  }

  depends_on = [google_project_service.this]
}

resource "google_org_policy_policy" "resource_locations" {
  name   = "${google_folder.this.name}/policies/gcp.resourceLocations"
  parent = google_folder.this.name

  spec {
    rules {
      values {
        allowed_values = ["in:us-locations"]
      }
    }
  }

  depends_on = [google_project_service.this]
}
