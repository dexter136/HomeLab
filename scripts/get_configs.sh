#!/bin/sh

overwrite=false

while getopts "o" arg; do
  case $arg in
    o) overwrite=true
  esac
done

terraform -chdir="./terraform/talos" output -raw talos_config > tmp/TALOS_CONFIG
terraform -chdir="./terraform/talos" output -raw kube_config > tmp/KUBE_CONFIG

if $overwrite; then
    cp tmp/TALOS_CONFIG ~/.talos/config
    cp tmp/KUBE_CONFIG ~/.kube/config
fi
