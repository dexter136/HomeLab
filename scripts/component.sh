#!/bin/bash

namespaced=("cluster-software")

diff=false
component=''
kustomize=false
while getopts "c:d" arg; do
  case $arg in
    c)  component=$OPTARG
        ;;
    d)  diff=true
        ;;
  esac
done

dir=$(find ./cluster -maxdepth 3 -type d -name $component)
if [ -z $dir ]; then
    echo "Could not find app directory. Find had no result."
    exit 1
fi

IFS='/' read -a dir_array <<< "$dir"
if [ ${#dir_array[@]} -ne 4 ]; then
    echo "Could not find app directory. Find returned $dir."
    exit 1
fi

echo "Found application ${dir_array[3]}."

if [ -f "$dir/Chart.yaml" ]; then
    echo "Found Chart.yaml, using helm."
else
    echo "Did not find Chart.yaml, using kustomize."
    kustomize=true
fi

if [[ " ${namespaced[@]} " =~ " ${dir_array[2]} " ]]; then
    namespace="${dir_array[3]}"
elif [ " ${dir_array[2]} " == " apps " ]; then
    namespace="default"
elif [ " ${dir_array[2]} " == " bootstrap " ]; then
    namespace="argocd"
else
    namespace="${dir_array[2]}"
fi

rm -rf "./tmp/${dir_array[3]}"

if $kustomize; then
    mkdir "./tmp/${dir_array[3]}"
    kustomize build $dir \
        --enable-helm \
        --enable-alpha-plugins \
        --enable-exec \
        --output "./tmp/${dir_array[3]}"
    echo "Wrote kustomize output to ./tmp/${dir_array[3]}"
else
    helm template \
        $component \
        $dir \
        --dependency-update \
        --include-crds \
        --namespace $namespace \
        --values "$dir/values.yaml" \
        --output-dir "./tmp/${dir_array[3]}"
    echo "Wrote helm output to ./tmp/${dir_array[3]}"
fi

if $diff; then

    if [ ! -d "./tmp/diffs" ]; then
        mkdir "./tmp/diffs"
    fi

    kubectl diff \
        -f ./tmp/${dir_array[3]} \
        --recursive \
        -n "$namspace" \
        > ./tmp/diffs/${dir_array[3]}.yaml

    echo "diff output written to ./tmp/diffs/${dir_array[3]}.yaml"
fi
