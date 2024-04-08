locals {
  talos_version = "v1.6.7"
  nodes         = concat(keys(var.controlplane), keys(var.worker))

  control_hosts = [for k, v in var.controlplane : {
    hostname = v.name
    ip       = k
  }]

  worker_hosts = [for k, v in var.worker : {
    aliases = v.name
    ip      = k
  }]

  extraHostEntries = local.control_hosts
}
