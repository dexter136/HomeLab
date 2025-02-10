resource "cloudflare_api_token" "system_api_token" {
  name = "homelab_token"
  policies = [{
    effect = "allow"
    permission_groups = [{
      id = "c8fed203ed3043cba015a93ad1616f1f"
    }, {
      id = "4755a26eedb94da69e1066d98aa820be"
    }]
    resources = {
        "com.cloudflare.api.account.zone.${var.cloudflare_homelab_zone}" = "*"
    }
  }]
  condition = {
    request_ip = {
      in = local.public_ips
    }
  }
}

resource "cloudflare_ruleset" "firewall" {
  kind = "zone"
  name = "homelab firewall"
  phase = "http_request_firewall_custom"
  rules = [{
    action = "block"
    description = "Firewall rule to block bots determined by CF"
    enabled = true
    expression = "(cf.client.bot)"
  },
  {
    action      = "block"
    description = "Firewall rule to block medium threats"
    enabled     = true
    expression  = "(cf.threat_score gt 14)"
  }]
  zone_id = var.cloudflare_homelab_zone
  description = "My ruleset to execute managed rulesets"
}

resource "random_password" "tunnel_secret" {
  length  = 64
  special = false
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "homelab_tunnel" {
  account_id = var.cloudflare_account_id
  name = "homelab"
  config_src = "local"
  tunnel_secret = random_password.tunnel_secret.result
}

resource "cloudflare_dns_record" "tunnel" {
  zone_id = var.cloudflare_homelab_zone
  comment = "cloudflared tunnel"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id}.cfargotunnel.com"
  name = "homelab-tunnel"
  proxied = true
  ttl = 1
  type = "CNAME"
}
