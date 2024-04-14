resource "kubernetes_secret" "argocd-webhook" {
  metadata {
    name      = "argocd-webhook"
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    "webhook.github.secret" = var.github_webhook
  }
}
