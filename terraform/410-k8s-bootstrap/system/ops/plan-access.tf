# Helm stores release records as Secrets. The plan identity may read Secrets only in
# the namespace that holds those records, never ArgoCD's own Secrets.
resource "kubernetes_role_v1" "helm_release_reader" {
  metadata {
    name      = "helm-release-reader"
    namespace = kubernetes_namespace_v1.release.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding_v1" "plan_identity" {
  metadata {
    name      = "terraform-plan"
    namespace = kubernetes_namespace_v1.release.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.helm_release_reader.metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = local.plan_identity
  }
}
