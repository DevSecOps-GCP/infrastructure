data "terraform_remote_state" "organization" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "000-organization"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "400-k8s/system/ops"
  }
}

locals {
  cluster          = data.terraform_remote_state.cluster.outputs.cluster
  plan_identity    = data.terraform_remote_state.organization.outputs.tf_plan_service_account
  argocd_namespace = "argocd"
}
