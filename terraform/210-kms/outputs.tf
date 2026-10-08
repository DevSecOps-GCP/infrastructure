output "vault_unseal_key" {
  value = {
    project  = local.project
    location = google_kms_key_ring.vault.location
    key_ring = google_kms_key_ring.vault.name
    key      = google_kms_crypto_key.vault_unseal.name
    id       = google_kms_crypto_key.vault_unseal.id
  }
}
