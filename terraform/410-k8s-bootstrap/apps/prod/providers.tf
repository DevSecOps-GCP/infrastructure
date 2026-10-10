terraform {
  required_version = "~> 1.16"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.3"
    }
  }
}

provider "google" {}

data "google_client_config" "this" {}

# DNS-based control-plane endpoint: publicly trusted TLS, access decided by IAM.
provider "kubernetes" {
  host  = "https://${local.cluster.dns_endpoint}"
  token = data.google_client_config.this.access_token
}
