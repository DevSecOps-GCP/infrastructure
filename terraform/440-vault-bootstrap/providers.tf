terraform {
  required_version = "~> 1.16"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.12"
    }
  }
}

# Applied by a human with the root token in VAULT_TOKEN, through a port-forward to the
# active Vault pod. The certificate is verified against the internal hostname.
provider "vault" {
  address         = var.vault_addr
  tls_server_name = var.tls_server_name
}
