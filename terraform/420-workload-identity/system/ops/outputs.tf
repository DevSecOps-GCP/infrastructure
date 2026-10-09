output "service_accounts" {
  value = {
    cert_manager = google_service_account.cert_manager.email
  }
}
