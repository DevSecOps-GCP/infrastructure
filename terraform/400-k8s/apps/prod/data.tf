data "terraform_remote_state" "projects" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "100-projects"
  }
}

data "terraform_remote_state" "network" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "200-network"
  }
}

data "terraform_remote_state" "registry" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "161-artifact-registry"
  }
}

locals {
  project  = data.terraform_remote_state.projects.outputs.project_ids["prod"]
  region   = data.terraform_remote_state.network.outputs.region
  network  = data.terraform_remote_state.network.outputs.network_id
  subnet   = data.terraform_remote_state.network.outputs.subnets["prod"]
  registry = data.terraform_remote_state.registry.outputs.repository
}
