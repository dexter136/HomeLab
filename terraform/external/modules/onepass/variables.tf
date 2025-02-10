variable "onepass_service_account_token" {
  type = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type = string
  sensitive = true
}

variable "cloudflared_credentials" {
  type = string
  sensitive = true
}
