resource "google_storage_bucket" "tfstate" {
  name                        = "${var.project_id}-tfstate"
  location                    = var.state_bucket_location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.this]
}
