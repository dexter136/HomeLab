resource "talos_machine_secrets" "cluster" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  machine_type       = "controlplane"
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.cluster.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches = [
    yamlencode({
      cluster = {
        allowSchedulingOnControlPlanes = true
        apiServer = {
          certSANs = ["kube.dex136.xyz", "192.168.1.230", "127.0.0.1"]
          disablePodSecurityPolicy = true
        }
        network = {
          cni = {
            name = "none"
          }
        }
        proxy = {
          disabled = true
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
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
}

data "talos_client_configuration" "cluster" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.cluster.client_configuration
  nodes                = local.nodes
  endpoints            = ["192.168.1.231"]
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = var.controlplane
  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.key
  config_patches = [yamlencode(local.machine_configs[each.key])]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = var.worker
  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.key
  config_patches = [yamlencode(local.machine_configs[each.key])]
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
