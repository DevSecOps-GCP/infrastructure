# Videos are never public: browsers upload and stream them with short-lived signed URLs
# issued by the backend.
resource "google_storage_bucket" "videos" {
  project                     = local.project
  name                        = var.bucket_name
  location                    = upper(local.region)
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  cors {
    origin          = [var.app_origin]
    method          = ["GET", "HEAD", "PUT"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}
