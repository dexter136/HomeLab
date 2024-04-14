variable "cloudflare_email" {
  type = string
}

variable "cloudflare_api_key" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type = string
}

variable "pihole_password" {
  type      = string
  sensitive = true
}

variable "github_webhook" {
  type      = string
  sensitive = true
}
