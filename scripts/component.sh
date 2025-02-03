#!/bin/bash

kustomizeApps=("statuspage" "onepassword-connect" "poddownloader" "pg-atuin")

diff=false
namespace=''
component=''
while getopts "c:n:d" arg; do
  case $arg in
    c)  component=$OPTARG
        ;;
    n)  namespace=$OPTARG
        ;;
    d)  diff=true
        ;;
  esac
done

dir=$(find . -maxdepth 3 -type d -name $component)
echo $dir
if [ -z $dir ]; then
    echo "Could not find app directory. Find had no result."
    exit 1
fi

IFS='/' read -a dir_array <<< "$dir"
if [ ${#dir_array[@]} -ne 4 ]; then
    echo "Could not find app directory. Find returned $dir."
    exit 1
fi

echo "Found application ${dir_array[3]}. Running build."

if [[ " ${kustomizeApps[@]} " =~ " $component " ]]; then
    kustomize build $dir \
        --enable-helm \
        --enable-alpha-plugins \
        --enable-exec \
        > ./tmp/${dir_array[3]}_render.yaml
    echo "Wrote kustomize output to ./tmp/${dir_array[3]}_render.yaml"
else
    echo $namespace
    helm template \
        $component \
        $dir \
        --dependency-update \
        --include-crds \
        --namespace $namespace \
        --values "$dir/values.yaml" \
        > ./tmp/${dir_array[3]}_render.yaml
    echo "Wrote helm output to ./tmp/${dir_array[3]}_render.yaml"
fi

if $diff; then
    echo "Running diff..."

    kubectl diff \
        -f ./tmp/${dir_array[3]}_render.yaml \
        -n "$namspace" \
        > ./tmp/${dir_array[3]}_diff.yaml

    echo "diff output written to ./tmp/${dir_array[3]}_diff.yaml"
fi
