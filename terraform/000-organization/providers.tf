terraform {
  required_version = "~> 1.16"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.6"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  # Org Policy and Billing Budget APIs require a quota project with user credentials.
  billing_project       = var.project_id
  user_project_override = true
}
