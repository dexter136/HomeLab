#!/bin/bash

#Namespaces
kubectl create ns argocd
kubectl create ns network
kubectl create ns longhorn

#CSR approval
./scripts/component.sh -c kubelet-csr-approver
kubectl apply -f ./tmp/kubelet-csr-approver_kustomize.yml -n kube-system
echo "Applied kubelet-csr-approver. Sleeping 30 seconds"
sleep 30

#CRDs
./scripts/component.sh -c prometheus-operator-crds
kubectl apply -f ./tmp/prometheus-operator-crds_kustomize.yml
echo "Applied prometheus-operator-crds. Sleeping 30 seconds"
sleep 30

#CoreDNS
./scripts/component.sh -c coredns
kubectl apply -f ./tmp/coredns_kustomize.yml -n kube-system
echo "Applied coredns. Sleeping 30 seconds"
sleep 30

#Ingress nginx
./scripts/component.sh -c ingress-nginx
kubectl apply -f ./tmp/ingress-nginx_kustomize.yml -n network
echo "Applied ingress-nginx. Sleeping 30 seconds"
sleep 30

#External DNS
./scripts/component.sh -c external-dns
kubectl apply -f ./tmp/external-dns_kustomize.yml -n network
echo "Applied external-dns. Sleeping 30 seconds"
sleep 30

#Cert manager
./scripts/component.sh -c cert-manager
kubectl apply -f ./tmp/cert-manager_kustomize.yml -n network
echo "Applied cert-manager. Sleeping 30 seconds"
sleep 30

#Longhorn
./scripts/component.sh -c longhorn
kubectl apply -f ./tmp/longhorn_kustomize.yml -n longhorn
echo "Applied longhorn. Sleeping 60 seconds"
sleep 60

#ArgoCD
./scripts/component.sh -c argocd
kubectl apply -f ./tmp/argocd_kustomize.yml -n argocd
echo "Applied argocd. Sleeping 60 seconds"
sleep 60

#Bootstrap
./scripts/component.sh -c root
kubectl apply -f ./tmp/root_kustomize.yml -n argocd
echo "Applied root."
