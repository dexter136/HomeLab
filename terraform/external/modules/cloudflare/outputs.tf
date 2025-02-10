output "api_token" {
    sensitive = true
    value = cloudflare_api_token.system_api_token.value
}

output "cloudflared_credentials" {
  sensitive = true
  value = local.cloudflared_credentials
}
