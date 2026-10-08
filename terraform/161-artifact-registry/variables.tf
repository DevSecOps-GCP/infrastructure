variable "repository_id" {
  type = string
}

variable "app_repo_id" {
  description = "Numeric id of the GitHub repo whose release job (production environment, main) pushes images"
  type        = string
}
