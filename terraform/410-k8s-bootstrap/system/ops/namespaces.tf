resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = local.argocd_namespace
  }
}

resource "kubernetes_namespace_v1" "release" {
  metadata {
    name = var.release_namespace
  }
}
