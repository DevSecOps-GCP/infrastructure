data "terraform_remote_state" "projects" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "100-projects"
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
  cluster = data.terraform_remote_state.cluster.outputs.cluster
  # ArgoCD's Google service account (420-workload-identity/system/ops). GKE presents
  # Google identities to Kubernetes RBAC as their email.
  argocd_identity = "argocd@${data.terraform_remote_state.projects.outputs.project_ids["ops"]}.iam.gserviceaccount.com"
}
