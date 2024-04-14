resource "random_password" "tunnel_secret" {
  length  = 64
  special = false
}

resource "cloudflare_tunnel" "homelab" {
  account_id = var.cloudflare_account_id
  name       = "homelab"
  secret     = base64encode(random_password.tunnel_secret.result)
}

resource "cloudflare_record" "tunnel" {
  zone_id = data.cloudflare_zone.dex136.id
  type    = "CNAME"
  name    = "homelab-tunnel"
  value   = "${cloudflare_tunnel.homelab.id}.cfargotunnel.com"
  proxied = false
  ttl     = 1 # Auto
}

output "TunnelName" {
  value = cloudflare_tunnel.homelab.name
}

output "TunnelID" {
  value = cloudflare_tunnel.homelab.id
}

output "TunnelSecret" {
  value = base64encode(random_password.tunnel_secret.result)
}
