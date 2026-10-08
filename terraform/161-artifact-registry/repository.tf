resource "google_artifact_registry_repository" "images" {
  project       = local.project
  location      = local.region
  repository_id = var.repository_id
  description   = "Container images for DevSecOps Global"
  format        = "DOCKER"

  # A tag (the git SHA) always points to the image that was scanned and signed.
  docker_config {
    immutable_tags = true
  }

  # Image scanning happens in CI (Trivy); registry scanning is billed per image.
  vulnerability_scanning_config {
    enablement_config = "DISABLED"
  }

  cleanup_policy_dry_run = false

  cleanup_policies {
    id     = "keep-recent"
    action = "KEEP"

    most_recent_versions {
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-untagged"
    action = "DELETE"

    condition {
      tag_state  = "UNTAGGED"
      older_than = "604800s"
    }
  }

  cleanup_policies {
    id     = "delete-old"
    action = "DELETE"

    condition {
      tag_state  = "ANY"
      older_than = "2592000s"
    }
  }
}

# Only jobs in the app repo's "production" environment on main can push.
resource "google_artifact_registry_repository_iam_member" "app_release" {
  project    = google_artifact_registry_repository.images.project
  location   = google_artifact_registry_repository.images.location
  repository = google_artifact_registry_repository.images.name
  role       = "roles/artifactregistry.writer"
  member     = "principalSet://iam.googleapis.com/${local.pool}/attribute.apply_repository_id/${var.app_repo_id}"
}
