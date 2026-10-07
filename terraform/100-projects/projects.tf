locals {
  organization = data.terraform_remote_state.organization.outputs

  projects = {
    net = {
      name = "DevSecOps Global Network"
      apis = [
        "compute.googleapis.com",
        "container.googleapis.com", # required in the Shared VPC host for GKE service projects
        "dns.googleapis.com",
        "iap.googleapis.com",
        "servicenetworking.googleapis.com",
      ]
    }
    ops = {
      name = "DevSecOps Global Ops"
      apis = [
        "artifactregistry.googleapis.com",
        "cloudkms.googleapis.com",
        "compute.googleapis.com",
        "container.googleapis.com",
        "iamcredentials.googleapis.com",
        "storage.googleapis.com",
      ]
    }
    prod = {
      name = "DevSecOps Global Prod"
      apis = [
        "certificatemanager.googleapis.com",
        "compute.googleapis.com",
        "container.googleapis.com",
        "iamcredentials.googleapis.com",
        "redis.googleapis.com",
        "sqladmin.googleapis.com",
        "storage.googleapis.com",
      ]
    }
  }

  project_apis = merge([
    for project, config in local.projects : {
      for api in config.apis : "${project}/${api}" => { project = project, api = api }
    }
  ]...)
}

resource "google_project" "this" {
  for_each = local.projects

  project_id          = "${var.prefix}-${each.key}"
  name                = each.value.name
  folder_id           = local.organization.folder_id
  billing_account     = local.organization.billing_account
  auto_create_network = false

  labels = {
    environment = each.key
    managed_by  = "terraform"
  }
}

resource "google_project_service" "this" {
  for_each = local.project_apis

  project            = google_project.this[each.value.project].project_id
  service            = each.value.api
  disable_on_destroy = false
}
