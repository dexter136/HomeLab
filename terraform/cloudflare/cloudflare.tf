data "cloudflare_zone" "dex136" {
  name = "dex136.xyz"
}

data "cloudflare_api_token_permission_groups" "all" {}

data "http" "public_ipv4" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  public_ips = [
    "${chomp(data.http.public_ipv4.response_body)}/32",
  ]
}

resource "cloudflare_ruleset" "firewall" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_firewall_custom"
  zone_id = data.cloudflare_zone.dex136.id
  rules {
    action      = "block"
    description = "Firewall rule to block bots determined by CF"
    enabled     = true
    expression  = "(cf.client.bot)"
  }
  rules {
    action      = "block"
    description = "Firewall rule to block medium threats"
    enabled     = true
    expression  = "(cf.threat_score gt 14)"
  }
  rules {
    action      = "block"
    description = "Firewall rule to allow only US, Canada, and European countries not under sanctions."
    enabled     = true
    expression  = "(ip.geoip.country ne \"US\" and ip.geoip.country ne \"CA\" and ip.geoip.continent ne \"EU\") or (ip.geoip.country eq \"RU\") or (ip.geoip.country eq \"BY\")"
  }
}

resource "cloudflare_api_token" "system_api_token" {
  name = "homelab_system_namespace"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.zone["Zone Read"],
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"]
    ]
    resources = {
      "com.cloudflare.api.account.zone.${data.cloudflare_zone.dex136.id}" = "*"
    }
  }

  condition {
    request_ip {
      in = local.public_ips
    }
  }
}

resource "cloudflare_page_rule" "plex" {
  zone_id  = data.cloudflare_zone.dex136.id
  target   = "plex.dex136.xyz/*"
  priority = 1

  actions {
    cache_level = "bypass"
  }
}

output "system_api_token" {
  value     = cloudflare_api_token.system_api_token.value
  sensitive = true
}
