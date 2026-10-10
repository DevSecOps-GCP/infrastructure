output "service_accounts" {
  value = {
    argocd       = google_service_account.argocd.email
    cert_manager = google_service_account.cert_manager.email
    vault        = google_service_account.vault.email
  }
}
