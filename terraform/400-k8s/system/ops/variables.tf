variable "cluster_name" {
  type = string
}

variable "zone_suffix" {
  description = "Single zone for the cluster and its node pool"
  type        = string
}

variable "machine_type" {
  type = string
}

variable "min_nodes" {
  type = number
}

variable "max_nodes" {
  type = number
}

variable "authorized_networks" {
  description = "Internal ranges allowed to reach the private control-plane endpoint"
  type        = map(string)
}

variable "operator_email" {
  description = "Human operator granted kubectl access; set from the TF_OPERATOR_EMAIL repository secret"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+$", var.operator_email))
    error_message = "operator_email must be an email address (repository secret TF_OPERATOR_EMAIL)."
  }
}
