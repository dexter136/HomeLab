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
  media_apps = ["sonarr", "prowlarr", "radarr"]
}

module "mediapass" {
  for_each = toset(local.media_apps)
  source   = "./modules/media-secrets"
  pg_pass  = random_password.pg.result
  name     = each.key
}

resource "kubernetes_secret" "unpackerr-secret" {
  metadata {
    name      = "unpackerr-secret"
    namespace = "media"
  }

  data = {
    UN_RADARR_0_API_KEY = module.mediapass["radarr"].api_key
    UN_SONARR_0_API_KEY = module.mediapass["sonarr"].api_key
  }
}

resource "random_password" "grafana_pg" {
  length  = 16
  special = true
}

resource "random_password" "grafana_admin" {
  length  = 16
  special = true
}


resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana-secret"
    namespace = "monitoring"
  }

  data = {
    GF_DATABASE_NAME         = "grafana"
    GF_DATABASE_HOST         = "postgres-rw.database.svc.cluster.local:5432"
    GF_DATABASE_USER         = "grafana"
    GF_DATABASE_PASSWORD     = random_password.grafana_pg.result
    GF_DATABASE_SSL_MODE     = "disable"
    GF_DATABASE_TYPE         = "postgres"
    INIT_POSTGRES_DBNAME     = "grafana"
    INIT_POSTGRES_HOST       = "postgres-rw.database.svc.cluster.local"
    INIT_POSTGRES_USER       = "grafana"
    INIT_POSTGRES_PASS       = random_password.grafana_pg.result
    INIT_POSTGRES_SUPER_PASS = random_password.pg.result
  }
}

resource "kubernetes_secret" "grafana_admin" {
  metadata {
    name      = "grafana-admin"
    namespace = "monitoring"
  }

  data = {
    admin-user     = "admin"
    admin-password = random_password.grafana_admin.result
  }
}
