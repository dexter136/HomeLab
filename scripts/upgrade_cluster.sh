#!/bin/bash

./scripts/render_configs.sh


readarray nodeIPs < <(yq '.nodes[].ip' -o=j -I=0 configs/inventory.yaml)
factory=$(yq '.talos_factory_key' configs/inventory.yaml)
talos=$(yq '.talos_version' configs/inventory.yaml)

for node in "${nodeIPs[@]}"; do
    echo "Upgrading Talos on node ${node} to talos version ${talos}."
    talosctl --nodes $node upgrade \
        --image="factory.talos.dev/installer/${factory}:${talos}" \
        --wait=true --timeout=10m --preserve=true

    echo "Waiting for Talos to be healthy on node '${node}'."
    talosctl --nodes $node health \
        --wait-timeout=10m --server=false

    echo "Node ${node} has completed"
done

echo "All nodes completed."

kubectl delete pods --field-selector status.phase="Evicted" --all-namespaces --ignore-not-found=true
kubectl delete pods --field-selector status.phase="Failed" --all-namespaces --ignore-not-found=true
kubectl delete pods --field-selector status.phase="Succeded" --all-namespaces --ignore-not-found=true
