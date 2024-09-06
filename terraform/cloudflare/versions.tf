terraform {
  required_version = "~> 1.7.0"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "dexterslab"

    workspaces {
      name = "homelab-external-dep"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.41.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "random" {
}
