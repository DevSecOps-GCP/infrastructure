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

locals {
  project                = data.terraform_remote_state.projects.outputs.project_ids["prod"]
  dns_project            = data.terraform_remote_state.projects.outputs.project_ids["net"]
  region                 = data.terraform_remote_state.network.outputs.region
  network                = data.terraform_remote_state.network.outputs.network_id
  private_services_range = data.terraform_remote_state.network.outputs.private_services_range_name
  internal_zone          = data.terraform_remote_state.network.outputs.internal_zone
}
