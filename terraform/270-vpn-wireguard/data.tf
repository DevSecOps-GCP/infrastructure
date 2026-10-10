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

data "terraform_remote_state" "network" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "200-network"
  }
}

locals {
  project     = data.terraform_remote_state.projects.outputs.project_ids["net"]
  region      = data.terraform_remote_state.network.outputs.region
  zone        = "${local.region}-${var.zone_suffix}"
  subnet      = data.terraform_remote_state.network.outputs.vpn_subnet
  public_zone = data.terraform_remote_state.dns.outputs.zone_name
  domain      = trimsuffix(data.terraform_remote_state.dns.outputs.dns_name, ".")
}
