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

locals {
  project     = data.terraform_remote_state.projects.outputs.project_ids["prod"]
  dns_project = data.terraform_remote_state.projects.outputs.project_ids["net"]
  public_zone = data.terraform_remote_state.dns.outputs.zone_name
  fqdn        = "${var.hostname}.${trimsuffix(data.terraform_remote_state.dns.outputs.dns_name, ".")}"
}
