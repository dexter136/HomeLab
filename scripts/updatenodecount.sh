#!/bin/sh


nodecount=$(yq '.nodes | length' configs/inventory.yaml)

echo "Found $nodecount nodes in inventory."

echo "Updating fstrim parellism."
yq -i ".app-template.controllers.fstrim.cronjob.parallelism = $nodecount" cluster/kube-system/fstrim/values.yaml
