#!/bin/bash

./scripts/generate_configs.sh


readarray nodeIPs < <(yq '.nodes[].ip' -o=j -I=0 configs/inventory.yaml)
factory=$(yq '.talos_factory_key' configs/inventory.yaml)
talos=$(yq '.talos_version' configs/inventory.yaml)


echo "Starting cnpg maintenance"
kubectl cnpg maintenance set postgres --reusePVC -n database

for node in "${nodeIPs[@]}"; do
    echo "Upgrading Talos on node '${node}'"
    talosctl --nodes $node upgrade \
        --image="factory.talos.dev/installer/${factory}:${talos}" \
        --wait=true --timeout=10m --preserve=true

    echo "Waiting for Talos to be healthy on node '${node}'."
    talosctl --nodes $node health \
        --wait-timeout=10m --server=false

    echo "Node ${node} has completed"
done

echo "All nodes completed. Ending cnpg maintenance."
kubectl cnpg maintenance unset postgres --reusePVC -n database
echo "Database maintenance ended. Cleaning up pods."
kubectl delete pods --field-selector status.phase="Evicted" --all-namespaces --ignore-not-found=true
kubectl delete pods --field-selector status.phase="Failed" --all-namespaces --ignore-not-found=true
kubectl delete pods --field-selector status.phase="Succeded" --all-namespaces --ignore-not-found=true
