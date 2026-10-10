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
  project         = data.terraform_remote_state.projects.outputs.project_ids["ops"]
  dns_project     = data.terraform_remote_state.projects.outputs.project_ids["net"]
  region          = data.terraform_remote_state.network.outputs.region
  subnet          = data.terraform_remote_state.network.outputs.subnets["ops"]
  internal_zone   = data.terraform_remote_state.network.outputs.internal_zone
  internal_domain = trimsuffix(local.internal_zone.dns_name, ".")
}
