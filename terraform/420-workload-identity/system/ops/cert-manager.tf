resource "google_service_account" "cert_manager" {
  project      = local.project
  account_id   = "cert-manager"
  display_name = "cert-manager (ops cluster)"
}

resource "google_service_account_iam_member" "cert_manager_wi" {
  service_account_id = google_service_account.cert_manager.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.wi_pool}[cert-manager/cert-manager]"
}

# DNS-01 challenges: write access to the public zone only.
resource "google_dns_managed_zone_iam_member" "cert_manager" {
  project      = local.dns_project
  managed_zone = local.public_zone
  role         = "roles/dns.admin"
  member       = google_service_account.cert_manager.member
}
