variable "org_id" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "project_id" {
  description = "Seed project: Terraform state and CI identities"
  type        = string
}

variable "region" {
  description = "Region for all workloads; the folder may only create resources here"
  type        = string
}

variable "state_bucket_location" {
  description = "Location of the Terraform state bucket, independent of the workload region"
  type        = string
}

variable "folder_name" {
  type = string
}

variable "github_org_id" {
  description = "Numeric GitHub org id (immutable, unlike the org name)"
  type        = string
}

variable "infrastructure_repo_id" {
  description = "Numeric id of the infrastructure GitHub repo (survives renames, changes if recreated)"
  type        = string
}

variable "wireguard_instance" {
  description = "The only VM in the folder allowed an external IP"
  type        = string
}
