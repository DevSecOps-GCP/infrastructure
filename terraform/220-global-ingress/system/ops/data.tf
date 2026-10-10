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
  project         = data.terraform_remote_state.projects.outputs.project_ids["ops"]
  dns_project     = data.terraform_remote_state.projects.outputs.project_ids["net"]
  internal_domain = trimsuffix(data.terraform_remote_state.network.outputs.internal_zone.dns_name, ".")

  # The same names resolve from the internet (public zone) and from inside the VPC,
  # where the private zone for the internal domain takes precedence.
  zones = {
    public  = data.terraform_remote_state.dns.outputs.zone_name
    private = data.terraform_remote_state.network.outputs.internal_zone.name
  }

  records = {
    for pair in setproduct(keys(local.zones), var.hostnames) :
    "${pair[0]}/${pair[1]}" => { zone = local.zones[pair[0]], host = pair[1] }
  }
}
