resource "google_folder" "this" {
  display_name = var.folder_name
  parent       = "organizations/${var.org_id}"

  depends_on = [google_project_service.this]
}
