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
      }
    }
  }
}
