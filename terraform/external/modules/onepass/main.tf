resource "onepassword_item" "cloudflare" {
  vault = data.onepassword_vault.kubernetes.uuid

  title    = "cloudflare"
  category = "password"

  password_recipe {
    length  = 40
    symbols = false
  }

  section {
    label = "keys"

    field {
      label = "CLOUDFLARE_API_KEY"
      type  = "STRING"
      value = var.cloudflare_api_token
    }

    field {
        label = "CLOUDFLARED_CREDENTIALS"
        type = "STRING"
        value = var.cloudflared_credentials
    }
  }
}
