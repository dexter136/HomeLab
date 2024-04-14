resource "kubernetes_secret" "discord-secret" {
  metadata {
    name      = "discord-secret"
    namespace = "monitoring"
  }

  data = {
    "DISCORD_WEBHOOK" = var.DISCORD_WEBHOOK
  }
}

resource "kubernetes_config_map" "podcastdownload" {
  metadata {
    name      = "podcastdownload-config"
    namespace = "media"
  }

  data = {
    config = var.podcasts
  }
}

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
