#!/bin/bash

kubectl delete pods --field-selector status.phase="Evicted" --all-namespaces --ignore-not-found=true
kubectl delete pods --field-selector status.phase="Failed" --all-namespaces --ignore-not-found=true
kubectl delete pods --field-selector status.phase="Succeeded" --all-namespaces --ignore-not-found=true
