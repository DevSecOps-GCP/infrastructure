data "terraform_remote_state" "projects" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "100-projects"
  }
}

data "terraform_remote_state" "dns" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "190-dns"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "400-k8s/system/ops"
  }
}

data "terraform_remote_state" "kms" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "210-kms"
  }
}

locals {
  project      = data.terraform_remote_state.projects.outputs.project_ids["ops"]
  prod_project = data.terraform_remote_state.projects.outputs.project_ids["prod"]
  dns_project  = data.terraform_remote_state.projects.outputs.project_ids["net"]
  public_zone  = data.terraform_remote_state.dns.outputs.zone_name
  wi_pool      = data.terraform_remote_state.cluster.outputs.workload_identity_pool
  unseal_key   = data.terraform_remote_state.kms.outputs.vault_unseal_key
}
