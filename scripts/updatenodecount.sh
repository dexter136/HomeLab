#!/bin/sh


nodecount=$(yq '.nodes | length' configs/inventory.yaml)

echo "Found $nodecount nodes in inventory."

echo "Updating fstrim parellism."
yq -i ".controllers.fstrim.cronjob.parallelism = $nodecount" cluster/kube-system/fstrim/helmvalues.yaml

echo "Updating postgres cluster replicas."
yq -i "select(.kind == \"Cluster\").spec.instances = $nodecount" cluster/cluster-software/database/cluster.yaml
