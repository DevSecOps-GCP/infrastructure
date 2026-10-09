output "argocd" {
  value = {
    namespace     = kubernetes_namespace_v1.argocd.metadata[0].name
    chart_version = helm_release.argocd.version
    root_app_path = var.root_path
  }
}
