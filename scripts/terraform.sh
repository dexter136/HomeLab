#!/bin/sh

apply=false
upgrade=false
init=false
cluster=false
external=false
while getopts "auice" arg; do
  case $arg in
    a) apply=true;;
    u) upgrade=true;;
    i) init=true;;
    c) cluster=true;;
    e) external=true;;
  esac
done

if $external; then
    if $upgrade; then
        terraform -chdir="./terraform/cloudflare" init -upgrade
    elif $init; then
        terraform -chdir="./terraform/cloudflare"
    fi
    if $apply; then
        terraform -chdir="./terraform/cloudflare" apply -var-file=../../configs/generated_configs/external.tfvars -auto-approve
    else
        terraform -chdir="./terraform/cloudflare" plan -var-file=../../configs/generated_configs/external.tfvars -no-color > configs/generated_configs/cloudflare.tfplan
        cat configs/generated_configs/cloudflare.tfplan
    fi
fi
if $cluster; then
    if $upgrade; then
        terraform -chdir="./terraform/talos" init -upgrade
    elif $init; then
        terraform -chdir="./terraform/talos" init
    fi
    if $apply; then
        terraform -chdir="./terraform/talos" apply -var-file=../../configs/generated_configs/cluster-build.tfvars -auto-approve
    else
        terraform -chdir="./terraform/talos" plan -var-file=../../configs/generated_configs/cluster-build.tfvars -no-color > configs/generated_configs/talos.tfplan
        cat configs/generated_configs/talos.tfplan
    fi
fi
