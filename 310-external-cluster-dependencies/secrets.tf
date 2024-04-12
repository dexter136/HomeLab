resource "kubernetes_secret" "discord-secret" {
  metadata {
    name      = "discord-secret"
    namespace = "monitoring"
  }

  data = {
    "DISCORD_WEBHOOK" = var.DISCORD_WEBHOOK
  }
}

resource "kubernetes_secret" "podcastdownload" {
  metadata {
    name      = "podcastdownload-secret"
    namespace = "media"
  }

  data = {
    "PODCAST_0"  = var.PODCAST_0
    "PODCAST_1"  = var.PODCAST_1
    "PODCAST_2"  = var.PODCAST_2
    "PODCAST_3"  = var.PODCAST_3
    "PODCAST_4"  = var.PODCAST_4
    "FILEPATH_0" = var.FILEPATH_0
    "FILEPATH_1" = var.FILEPATH_1
    "FILEPATH_2" = var.FILEPATH_2
    "FILEPATH_3" = var.FILEPATH_3
    "FILEPATH_4" = var.FILEPATH_4
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
