locals {
  node_identities = merge(var.controlplane, var.worker)
  nodes           = keys(local.node_identities)
  control_hosts = [for k, v in var.controlplane : {
    hostname = v.name
    ip       = k
  }]

  worker_hosts = [for k, v in var.worker : {
    aliases = v.name
    ip      = k
  }]

  extraHostEntries = local.control_hosts

  machine_configs = { for k, v in local.node_identities :
    k => {
      machine = {
        install = {
          disk  = v.disk
          image = "factory.talos.dev/installer/${var.talos_factory_key}:${var.talos_version}"
        }
        kubelet = {
          extraMounts = [{
            destination = "/var/lib/longhorn"
            type        = "bind"
            source      = "/var/lib/longhorn"
            options     = ["bind", "rshared", "rw"]
          }]
        }
        network = {
          nameservers = ["192.168.1.230", "8.8.8.8"]
          interfaces = [{
            interface = v.interface
            addresses = ["${k}/24"]
            routes = [{
              network = "0.0.0.0/0"
              gateway = "192.168.1.1"
            }]
            dhcp = true
          }]
          hostname = "${v.name}"
        }
        features = {
          kubePrism = {
            enabled = true
            port    = 7445
          }
        }
        files = [
          {
            content     = <<EOT
[plugins."io.containerd.grpc.v1.cri"]
  enable_unprivileged_ports = true
  enable_unprivileged_icmp = true
[plugins."io.containerd.grpc.v1.cri".containerd]
  discard_unpacked_layers = false
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  discard_unpacked_layers = false
            EOT
            permissions = 0
            path        = "/etc/cri/conf.d/20-customization.part"
            op          = "create"
          },
          {
            content     = <<EOT
[ NFSMount_Global_Options ]
nfsvers=4.1
hard=True
noatime=True
nodiratime=True
rsize=131072
wsize=131072
nconnect=8
          EOT
            permissions = 420
            path        = "/etc/nfsmount.conf"
            op          = "overwrite"
          }
        ]
        sysctls = {
          "fs.inotify.max_queued_events"  = "65536"
          "fs.inotify.max_user_instances" = "8192"
          "fs.inotify.max_user_watches"   = "524288"
          "net.core.rmem_max"             = "2500000"
          "net.core.wmem_max"             = "2500000"
        }
      }
    }
  }
}
