resource "talos_machine_secrets" "cluster" {
  talos_version = local.talos_version
}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  machine_type       = "controlplane"
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.cluster.machine_secrets
  talos_version      = local.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches = [
    yamlencode({
      cluster = {
        allowSchedulingOnControlPlanes = true
        apiServer = {
          certSANs = ["kube.dex136.xyz", "192.168.1.230"]
        }
      }
    })
  ]
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.cluster_name
  machine_type       = "worker"
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.cluster.machine_secrets
  talos_version      = local.talos_version
  kubernetes_version = var.kubernetes_version
}

data "talos_client_configuration" "cluster" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.cluster.client_configuration
  nodes                = local.nodes
  endpoints            = ["https://192.168.1.230:6443"]
}

output "talos_config" {
  value     = data.talos_client_configuration.cluster.talos_config
  sensitive = true
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = var.controlplane
  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.init_ip
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = each.value.disk
          image = "factory.talos.dev/installer/4dd8e3a8b6203d3c14f049da8db4d3bb0d6d3e70c5e89dfcc1e709e81914f63c:v1.6.7"
        }
        network = {
          nameservers = ["192.168.1.230", "8.8.8.8"]
          interfaces = [{
            interface = each.value.interface
            addresses = ["${each.key}/24"]
            routes = [{
              network = "0.0.0.0/0"
              gateway = "192.168.1.1"
            }]
            dhcp = true
          }]
          hostname = "${each.value.name}"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = var.worker
  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.init_ip
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = each.value.disk
          image = "factory.talos.dev/installer/4dd8e3a8b6203d3c14f049da8db4d3bb0d6d3e70c5e89dfcc1e709e81914f63c:v1.6.7"
        }
        network = {
          nameservers = ["192.168.1.230", "8.8.8.8"]
          interfaces = [{
            interface = each.value.interface
            addresses = ["${each.key}/24"]
            routes = [{
              network = "0.0.0.0/0"
              gateway = "192.168.1.1"
            }]
            dhcp = true
          }]
          hostname = "${each.value.name}"
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "cluster" {
  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]
  node                 = local.nodes[0]
  client_configuration = talos_machine_secrets.cluster.client_configuration
}

data "talos_cluster_kubeconfig" "cluster" {
  depends_on = [
    talos_machine_bootstrap.cluster
  ]
  client_configuration = talos_machine_secrets.cluster.client_configuration
  node                 = local.nodes[0]
}

output "kube_config" {
  value     = data.talos_cluster_kubeconfig.cluster.kubeconfig_raw
  sensitive = true
}

