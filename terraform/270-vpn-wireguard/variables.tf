variable "instance_name" {
  description = "Must match the external-IP allow-list in 000-organization"
  type        = string
}

variable "zone_suffix" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "listen_port" {
  type = number
}

variable "tunnel_address" {
  description = "Server address inside the tunnel, with the client network prefix"
  type        = string
}

variable "routed_cidr" {
  description = "VPC range clients may reach through the tunnel"
  type        = string
}

variable "peers" {
  description = "VPN clients, identified by their public key"
  type = list(object({
    name       = string
    public_key = string
    address    = string
  }))

  validation {
    condition     = alltrue([for p in var.peers : can(regex("^[A-Za-z0-9+/]{42}[AEIMQUYcgkosw480]=$", p.public_key))])
    error_message = "Each peer public_key must be a base64 WireGuard key."
  }

  validation {
    condition     = alltrue([for p in var.peers : can(regex("^10\\.99\\.0\\.([2-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])/32$", p.address))])
    error_message = "Each peer address must be a /32 inside 10.99.0.0/24, excluding the server address."
  }

  validation {
    condition = (
      length(distinct([for p in var.peers : p.public_key])) == length(var.peers) &&
      length(distinct([for p in var.peers : p.address])) == length(var.peers)
    )
    error_message = "Peer public keys and addresses must be unique."
  }
}

variable "operator_email" {
  description = "Human operator granted IAP SSH; set from the TF_OPERATOR_EMAIL repository secret"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+$", var.operator_email))
    error_message = "operator_email must be an email address (repository secret TF_OPERATOR_EMAIL)."
  }
}
