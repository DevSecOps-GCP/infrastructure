# ArgoCD on the ops cluster manages everything inside prod, including CRDs and other
# cluster-scoped resources.
resource "kubernetes_cluster_role_binding_v1" "argocd" {
  metadata {
    name = "argocd-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = local.argocd_identity
  }
}
