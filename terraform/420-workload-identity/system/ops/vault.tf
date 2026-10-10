resource "google_service_account" "vault" {
  project      = local.project
  account_id   = "vault-server"
  display_name = "Vault (ops cluster)"
}

resource "google_service_account_iam_member" "vault_wi" {
  service_account_id = google_service_account.vault.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.wi_pool}[vault/vault]"
}

# Auto-unseal: encrypt/decrypt with the unseal key, and read its metadata. Nothing else.
resource "google_kms_crypto_key_iam_member" "vault_unseal" {
  for_each = toset([
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    "roles/cloudkms.viewer",
  ])

  crypto_key_id = local.unseal_key.id
  role          = each.value
  member        = google_service_account.vault.member
}
