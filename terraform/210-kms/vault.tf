resource "google_kms_key_ring" "vault" {
  project  = local.project
  name     = "vault"
  location = local.region
}

# Vault auto-unseal key. Losing it makes Vault's storage unrecoverable.
resource "google_kms_crypto_key" "vault_unseal" {
  name            = "vault-unseal"
  key_ring        = google_kms_key_ring.vault.id
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}
