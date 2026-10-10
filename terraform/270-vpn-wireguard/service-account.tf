resource "google_service_account" "vm" {
  project      = local.project
  account_id   = "${var.instance_name}-vm"
  display_name = "WireGuard VPN server"
}

resource "google_project_iam_member" "vm_logs" {
  project = local.project
  role    = "roles/logging.logWriter"
  member  = google_service_account.vm.member
}
