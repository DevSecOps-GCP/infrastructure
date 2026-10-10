resource "vault_jwt_auth_backend" "github" {
  path               = "github"
  description        = "GitHub Actions OIDC tokens"
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
  bound_issuer       = "https://token.actions.githubusercontent.com"
}

# Pull requests (any branch of the repository): read-only, for plans.
resource "vault_jwt_auth_backend_role" "terraform_plan" {
  backend         = vault_jwt_auth_backend.github.path
  role_name       = "terraform-plan"
  role_type       = "jwt"
  user_claim      = "sub"
  bound_audiences = [var.audience]
  bound_claims = {
    repository_id = var.repository_id
  }
  token_policies = [vault_policy.terraform_plan.name]
  token_ttl      = 900
  token_max_ttl  = 1800
}

# main branch in the protected production environment only, for applies.
resource "vault_jwt_auth_backend_role" "terraform_apply" {
  backend         = vault_jwt_auth_backend.github.path
  role_name       = "terraform-apply"
  role_type       = "jwt"
  user_claim      = "sub"
  bound_audiences = [var.audience]
  bound_claims = {
    repository_id = var.repository_id
    ref           = "refs/heads/main"
    environment   = "production"
  }
  token_policies = [vault_policy.terraform_apply.name]
  token_ttl      = 900
  token_max_ttl  = 1800
}
