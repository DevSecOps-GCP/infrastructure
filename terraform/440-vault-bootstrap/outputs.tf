output "github_auth" {
  value = {
    path     = vault_jwt_auth_backend.github.path
    audience = var.audience
    roles    = [vault_jwt_auth_backend_role.terraform_plan.role_name, vault_jwt_auth_backend_role.terraform_apply.role_name]
  }
}
