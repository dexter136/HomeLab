locals {
  config_directory = "../../configs/generated_configs"
  node_identities  = merge(var.controlplane, var.worker)
  nodes            = keys(local.node_identities)
  apply_mode       = "staged"
}

resource "talos_machine_secrets" "cluster" {
  talos_version = var.pinned_talos_version
}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  machine_type       = "controlplane"
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.cluster.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
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
  endpoints            = [local.nodes[0]]
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = var.controlplane
  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.key
  apply_mode                  = var.apply_mode
  config_patches              = [file("${local.config_directory}/${each.value}.yaml")]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = var.worker
  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.key
  apply_mode                  = var.apply_mode
  config_patches              = [file("${local.config_directory}/${each.value}.yaml")]
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

output "talos_config" {
  value     = data.talos_client_configuration.cluster.talos_config
  sensitive = true
}

output "kube_config" {
  value     = data.talos_cluster_kubeconfig.cluster.kubeconfig_raw
  sensitive = true
}
