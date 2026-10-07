output "project_ids" {
  value = { for k, p in google_project.this : k => p.project_id }
}

output "project_numbers" {
  value = { for k, p in google_project.this : k => p.number }
}

output "host_project_id" {
  value = google_compute_shared_vpc_host_project.net.project
}
