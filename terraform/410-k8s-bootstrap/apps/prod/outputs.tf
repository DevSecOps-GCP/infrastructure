output "argocd_identity" {
  description = "Identity bound to cluster-admin in prod"
  value       = local.argocd_identity
}
