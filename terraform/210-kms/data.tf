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
  project = data.terraform_remote_state.projects.outputs.project_ids["ops"]
  region  = data.terraform_remote_state.network.outputs.region
}
