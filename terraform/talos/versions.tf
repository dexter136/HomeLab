terraform {
  required_version = "~> 1.8.0"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "dexterslab"

    workspaces {
      name = "homelab-talos"
    }
  }

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.0"
    }
  }
}
