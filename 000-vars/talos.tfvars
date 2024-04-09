controlplane = {
  "192.168.1.231" = {
    disk      = "/dev/nvme0n1"
    interface = "eno1"
    name      = "control-0"
  }
  "192.168.1.232" = {
    disk      = "/dev/sda"
    interface = "eno1"
    name      = "control-1"
  }
  "192.168.1.233" = {
    disk      = "/dev/nvme0n1"
    interface = "eno1"
    name      = "control-2"
  }
}

worker = {
  "192.168.1.234" = {
    disk      = "/dev/nvme0n1"
    interface = "eno1"
    name      = "worker-0"
  }
}

cluster_name = "aisling-homelab"

cluster_endpoint = "https://kube.dex136.xyz:6443"

kubernetes_version = "1.29.2"
