locals {
  folder_constraints = [
    "compute.requireOsLogin",
    "compute.requireShieldedVm",
    "compute.skipDefaultNetworkCreation",
    "iam.automaticIamGrantsForDefaultServiceAccounts",
    "iam.disableServiceAccountKeyCreation",
    "iam.disableServiceAccountKeyUpload",
    "sql.restrictPublicIp",
    "storage.publicAccessPrevention",
    "storage.uniformBucketLevelAccess",
  ]

  # The seed project sits outside the folder but holds the CI identities and all state.
  seed_constraints = [
    "iam.automaticIamGrantsForDefaultServiceAccounts",
    "iam.disableServiceAccountKeyCreation",
    "iam.disableServiceAccountKeyUpload",
    "storage.publicAccessPrevention",
    "storage.uniformBucketLevelAccess",
  ]

  enforced = merge(
    { for c in local.folder_constraints : c => { parent = google_folder.this.name, constraint = c } },
    { for c in local.seed_constraints : "seed/${c}" => { parent = "projects/${var.project_id}", constraint = c } },
  )
}

resource "google_org_policy_policy" "enforced" {
  for_each = local.enforced

  name   = "${each.value.parent}/policies/${each.value.constraint}"
  parent = each.value.parent

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
        allowed_values = ["in:${var.region}-locations"]
      }
    }
  }

  depends_on = [google_project_service.this]
}

resource "google_org_policy_policy" "vm_external_ip" {
  name   = "${google_folder.this.name}/policies/compute.vmExternalIpAccess"
  parent = google_folder.this.name

  spec {
    rules {
      values {
        allowed_values = [var.wireguard_instance]
      }
    }
  }

  depends_on = [google_project_service.this]
}
