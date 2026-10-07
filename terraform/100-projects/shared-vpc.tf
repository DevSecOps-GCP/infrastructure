resource "google_compute_shared_vpc_host_project" "net" {
  project = google_project.this["net"].project_id

  depends_on = [google_project_service.this["net/compute.googleapis.com"]]
}

resource "google_compute_shared_vpc_service_project" "this" {
  for_each = toset(["ops", "prod"])

  host_project    = google_compute_shared_vpc_host_project.net.project
  service_project = google_project.this[each.key].project_id

  depends_on = [google_project_service.this]
}
