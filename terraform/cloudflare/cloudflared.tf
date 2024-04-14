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
  value     = cloudflare_tunnel.homelab.name
  sensitive = true
}

output "TunnelID" {
  value     = cloudflare_tunnel.homelab.id
  sensitive = true
}

output "TunnelSecret" {
  value     = random_password.tunnel_secret.result
  sensitive = true
}
