#!/bin/bash

readarray nodeIPs < <(yq '.nodes[].ip' -o=j -I=0 configs/inventory.yaml)

for node in "${nodeIPs[@]}"; do
    echo "Restarting node '${node}'"
    talosctl --nodes $node reboot \
        --wait=true --timeout=10m

    echo "Waiting for Talos to be healthy on node '${node}'."
    talosctl --nodes $node health \
        --wait-timeout=10m --server=false

    echo "Node ${node} has completed"
done

echo "All nodes completed."
./scripts/pod_cleanup.sh
