variable "argocd_chart_version" {
  type = string
}

variable "argocd_apps_chart_version" {
  type = string
}

variable "release_namespace" {
  description = "Holds only Helm release records, readable by the plan identity"
  type        = string
}

variable "repo_url" {
  type = string
}

variable "root_path" {
  description = "Directory the root Application syncs"
  type        = string
}
