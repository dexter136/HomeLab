#!/bin/sh

apply=false
upgrade=false
cluster=false
external=false
generate=false
apply_mode=""
while getopts "agucem:" arg; do
  case $arg in
    a) apply=true;;
    g) generate=true;;
    u) upgrade=true;;
    c) cluster=true;;
    e) external=true;;
    m) apply_mode="-var=apply_mode=${OPTARG}"
  esac
done

if $generate; then
    ./scripts/generate_configs.sh
fi

if $external; then
    if $upgrade; then
        terraform -chdir="./terraform/cloudflare" init -upgrade
    else
        terraform -chdir="./terraform/cloudflare"
    fi
    if $apply; then
        terraform -chdir="./terraform/cloudflare" apply -var-file=../../configs/generated_configs/external.tfvars.json -auto-approve
    else
        terraform -chdir="./terraform/cloudflare" plan -var-file=../../configs/generated_configs/external.tfvars.json -no-color
    fi
fi
if $cluster; then
    if $upgrade; then
        terraform -chdir="./terraform/talos" init -upgrade
    else
        terraform -chdir="./terraform/talos" init
    fi
    if $apply; then
        terraform -chdir="./terraform/talos" apply -var-file=../../configs/generated_configs/cluster-build.tfvars $apply_mode -auto-approve
    else
        terraform -chdir="./terraform/talos" plan -var-file=../../configs/generated_configs/cluster-build.tfvars $apply_mode
    fi
fi
