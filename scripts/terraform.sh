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
    ./scripts/render_configs.sh
fi

if $external; then
    if $upgrade; then
        tofu -chdir="./terraform/external" init -upgrade
    else
        tofu -chdir="./terraform/external" init
    fi
    if $apply; then
        tofu -chdir="./terraform/external" apply -var-file=../../tmp/external.tfvars.json -auto-approve
    else
        tofu -chdir="./terraform/external" plan -var-file=../../tmp/external.tfvars.json -no-color
    fi
fi
if $cluster; then
    if $upgrade; then
        tofu -chdir="./terraform/talos" init -upgrade
    else
        tofu -chdir="./terraform/talos" init
    fi
    if $apply; then
        tofu -chdir="./terraform/talos" apply -var-file=../../tmp/cluster-build.tfvars $apply_mode -auto-approve
    else
        tofu -chdir="./terraform/talos" plan -var-file=../../tmp/cluster-build.tfvars $apply_mode
    fi
fi
