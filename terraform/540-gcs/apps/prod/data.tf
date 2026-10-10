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

data "terraform_remote_state" "cluster" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "400-k8s/apps/prod"
  }
}

locals {
  project = data.terraform_remote_state.projects.outputs.project_ids["prod"]
  region  = data.terraform_remote_state.network.outputs.region
  wi_pool = data.terraform_remote_state.cluster.outputs.workload_identity_pool
}
