# IAP SSH with OS Login, scoped to this VM only.
resource "google_iap_tunnel_instance_iam_member" "operator" {
  project  = local.project
  zone     = local.zone
  instance = google_compute_instance.wireguard.name
  role     = "roles/iap.tunnelResourceAccessor"
  member   = "user:${var.operator_email}"
}

resource "google_compute_instance_iam_member" "operator" {
  project       = local.project
  zone          = local.zone
  instance_name = google_compute_instance.wireguard.name
  role          = "roles/compute.osAdminLogin"
  member        = "user:${var.operator_email}"
}

# OS Login to a VM running as a service account requires acting as that account.
resource "google_service_account_iam_member" "operator" {
  service_account_id = google_service_account.vm.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${var.operator_email}"
}
