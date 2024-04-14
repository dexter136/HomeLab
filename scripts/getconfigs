#!/bin/sh

overwrite=false

while getopts "o" arg; do
  case $arg in
    o) overwrite=true
  esac
done

terraform -chdir="./terraform/talos" output -raw talos_config > configs/generated_configs/TALOS_CONFIG
terraform -chdir="./terraform/talos" output -raw kube_config > configs/generated_configs/KUBE_CONFIG

if $overwrite; then
    cp configs/generated_configs/TALOS_CONFIG ~/.talos/config
    cp configs/generated_configs/KUBE_CONFIG ~/.kube/config
fi
