data "terraform_remote_state" "projects" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "100-projects"
  }
}

locals {
  host_project    = data.terraform_remote_state.projects.outputs.host_project_id
  project_numbers = data.terraform_remote_state.projects.outputs.project_numbers
}
