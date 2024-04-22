#!/bin/sh

#Get talos schematic ID and update inventory.yaml
resp=$(curl -X POST --data-binary @configs/schematic.yaml https://factory.talos.dev/schematics)
schematic=$(echo $resp | jq -r '.id')
yq -i ".talos_factory_key = \"$schematic\"" configs/inventory.yaml

#Build gomplate templates
gomplate -f configs/templates/machineconfig.yaml.tmpl
gomplate -f configs/templates/cluster-build.tfvars.tmpl

#Decrypt tfvars
sops --decrypt configs/external.tfvars.json > configs/generated_configs/external.tfvars.json
