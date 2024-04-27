#!/bin/bash

diff=false
namespace=''
component=''
while getopts "c:d" arg; do
  case $arg in
    c)  component=$OPTARG
        ;;
    d)  diff=true
        namespace=$OPTARG
        ;;
  esac
done

dir=$(find -maxdepth 3 -type d -name $component)
echo $dir
if [ -z $dir ]; then
    echo "Could not find app directory. Find had no result."
    exit 1
fi

IFS='/' read -a dir_array <<< $dir

if [ ${#dir_array[@]} -ne 4 ]; then
    echo "Could not find app directory. Find returned $dir."
    exit 1
fi

echo "Found application ${dir_array[3]}. Running kustomize build"

kustomize build $dir \
    --load-restrictor=LoadRestrictionsNone \
    --enable-helm \
    --enable-alpha-plugins \
    --enable-exec \
    > ./tmp/${dir_array[3]}_kustomize.yaml

echo "Wrote kustomize output to ./tmp/${dir_array[3]}_kustomize.yaml"

if $diff; then
    echo "Running diff against namespace $namespace"

    kubectl diff \
        -f ./tmp/${dir_array[3]}_kustomize.yaml \
        > ./tmp/${dir_array[3]}_diff.yaml

    echo "diff output written to ./tmp/${dir_array[3]}_diff.yaml"
fi
