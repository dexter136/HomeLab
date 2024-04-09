output "talos_config" {
  value     = data.talos_client_configuration.cluster.talos_config
  sensitive = true
}

output "kube_config" {
  value     = data.talos_cluster_kubeconfig.cluster.kubeconfig_raw
  sensitive = true
}
