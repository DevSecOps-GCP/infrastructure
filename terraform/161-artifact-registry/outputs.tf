output "repository" {
  value = {
    project  = google_artifact_registry_repository.images.project
    location = google_artifact_registry_repository.images.location
    name     = google_artifact_registry_repository.images.name
    url      = "${google_artifact_registry_repository.images.location}-docker.pkg.dev/${google_artifact_registry_repository.images.project}/${google_artifact_registry_repository.images.name}"
  }
}
