# Plans read Vault configuration; no secret values.
resource "vault_policy" "terraform_plan" {
  name   = "terraform-plan"
  policy = <<-EOT
    path "sys/auth"            { capabilities = ["read"] }
    path "sys/mounts"          { capabilities = ["read"] }
    path "sys/mounts/*"        { capabilities = ["read"] }
    path "sys/policies/acl"    { capabilities = ["list"] }
    path "sys/policies/acl/*"  { capabilities = ["read"] }
    path "auth/+/config"       { capabilities = ["read"] }
    path "auth/+/role"         { capabilities = ["list"] }
    path "auth/+/role/*"       { capabilities = ["read"] }
  EOT
}

# Applies manage auth methods, secret engines and policies, but never the bootstrap
# itself: the GitHub auth method and the terraform-* policies stay human-managed.
resource "vault_policy" "terraform_apply" {
  name   = "terraform-apply"
  policy = <<-EOT
    path "sys/auth"            { capabilities = ["read"] }
    path "sys/auth/*"          { capabilities = ["create", "read", "update", "delete", "sudo"] }
    path "sys/mounts"          { capabilities = ["read"] }
    path "sys/mounts/*"        { capabilities = ["create", "read", "update", "delete"] }
    path "sys/policies/acl"    { capabilities = ["list"] }
    path "sys/policies/acl/*"  { capabilities = ["create", "read", "update", "delete"] }
    path "auth/+/*"            { capabilities = ["create", "read", "update", "delete", "list"] }

    path "sys/auth/github"            { capabilities = ["deny"] }
    path "auth/github/*"              { capabilities = ["deny"] }
    path "sys/policies/acl/terraform-*" { capabilities = ["deny"] }
  EOT
}
