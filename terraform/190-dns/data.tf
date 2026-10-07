data "terraform_remote_state" "projects" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "100-projects"
  }
}

data "google_dns_keys" "public" {
  project      = local.project
  managed_zone = google_dns_managed_zone.public.id
}
