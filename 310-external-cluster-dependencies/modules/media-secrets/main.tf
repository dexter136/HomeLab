resource "random_password" "api" {
  length  = 32
  special = false
}

resource "random_password" "pg" {
  length  = 16
  special = true
  override_special = "!@#$%&*()-_=+?"
}

resource "kubernetes_secret" "secret" {
  metadata {
    name      = "${var.name}-secret"
    namespace = "media"
  }

  data = {
    "${upper(var.name)}__API_KEY" = random_password.api.result
    "${upper(var.name)}__POSTGRES_HOST" = "postgres-rw.database.svc.cluster.local"
    "${upper(var.name)}__POSTGRES_PORT" = "5432"
    "${upper(var.name)}__POSTGRES_USER" = "${var.name}"
    "${upper(var.name)}__POSTGRES_PASSWORD" = random_password.pg.result
    "${upper(var.name)}__POSTGRES_MAIN_DB" = "${var.name}_main"
    "${upper(var.name)}__POSTGRES_LOG_DB" = "${var.name}_log"
    INIT_POSTGRES_DBNAME = "${var.name}_main ${var.name}_log"
    INIT_POSTGRES_HOST = "postgres-rw.database.svc.cluster.local"
    INIT_POSTGRES_USER = var.name
    INIT_POSTGRES_PASS = random_password.pg.result
    INIT_POSTGRES_SUPER_PASS = var.pg_pass
  }
}
