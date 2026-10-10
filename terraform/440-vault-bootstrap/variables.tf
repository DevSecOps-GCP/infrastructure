variable "vault_addr" {
  type = string
}

variable "tls_server_name" {
  type = string
}

variable "repository_id" {
  description = "Numeric id of the infrastructure GitHub repository"
  type        = string
}

variable "audience" {
  description = "Audience the pipeline requests in its GitHub OIDC token for Vault"
  type        = string
}
