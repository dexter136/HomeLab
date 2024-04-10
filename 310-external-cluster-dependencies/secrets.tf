resource "kubernetes_secret" "discord-secret" {
  metadata {
    name      = "discord-secret"
    namespace = "monitoring"
  }

  data = {
    "DISCORD_WEBHOOK" = var.DISCORD_WEBHOOK
  }
}


resource "random_password" "pg" {
  length  = 16
  special = true
}

resource "kubernetes_secret" "postgres-secret" {
  metadata {
    name      = "cloudnative-pg-secret"
    namespace = "database"
  }

  data = {
    username = "postgres"
    password = random_password.pg.result
  }
}

locals {
  media_apps = ["sonarr", "prowlarr"]
}

module "mediapass" {
  for_each = toset(local.media_apps)
  source   = "./modules/media-secrets"
  pg_pass  = random_password.pg.result
  name     = each.key
}
