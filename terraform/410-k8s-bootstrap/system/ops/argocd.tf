resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace_v1.release.metadata[0].name

  values = [file("${path.module}/values/argocd.yaml")]

  set = [{
    name  = "namespaceOverride"
    value = kubernetes_namespace_v1.argocd.metadata[0].name
  }]
}

resource "helm_release" "root_app" {
  name       = "argocd-root"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = var.argocd_apps_chart_version
  namespace  = kubernetes_namespace_v1.release.metadata[0].name

  values = [templatefile("${path.module}/values/root-app.yaml.tftpl", {
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name
    repo_url  = var.repo_url
    path      = var.root_path
  })]

  depends_on = [helm_release.argocd]
}
