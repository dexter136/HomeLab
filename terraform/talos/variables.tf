variable "controlplane" {
  type = map(any)
}

variable "worker" {
  type = map(any)
}

variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "pinned_talos_version" {
  type    = string
  default = "v1.6.7"
}

variable "talos_version" {
  type = string
}

variable "apply_mode" {
  type    = string
  default = "auto"
}
