#!/bin/sh

gomplate -f configs/templates/machineconfig.yaml.tmpl
gomplate -f configs/templates/cluster-build.tfvars.tmpl

sops --decrypt configs/external.tfvars.json > configs/generated_configs/external.tfvars.json
