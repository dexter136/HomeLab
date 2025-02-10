#!/bin/bash

#Namespaces
kubectl create ns argocd
kubectl create ns network
kubectl create ns longhorn
kubectl create ns onepassword-connect
echo "Created namespaces. Sleeping 30 seconds"

#secret
kubectl apply -f ./tmp/connect_secret.yaml

#CSR approval
./scripts/component.sh -c kubelet-csr-approver -n kube-system
kubectl apply -f ./tmp/kubelet-csr-approver_render.yaml -n kube-system
echo "Applied kubelet-csr-approver. Sleeping 30 seconds"
sleep 30

#CRDs
./scripts/component.sh -c prometheus-operator-crds
kubectl apply -f ./tmp/prometheus-operator-crds_render.yaml
echo "Applied prometheus-operator-crds. Sleeping 30 seconds"
sleep 30

#CoreDNS
./scripts/component.sh -c coredns -n kube-system
kubectl apply -f ./tmp/coredns_render.yaml -n kube-system
echo "Applied coredns. Sleeping 30 seconds"
sleep 30

#Ingress nginx
./scripts/component.sh -c ingress-nginx -n network
kubectl apply -f ./tmp/ingress-nginx_render.yaml -n network
echo "Applied ingress-nginx. Sleeping 30 seconds"
sleep 30

#External DNS
./scripts/component.sh -c external-dns -n network
kubectl apply -f ./tmp/external-dns_render.yaml -n network
echo "Applied external-dns. Sleeping 30 seconds"
sleep 30

#Cert manager
./scripts/component.sh -c cert-manager -n network
kubectl apply -f ./tmp/cert-manager_render.yaml -n network
echo "Applied cert-manager. Sleeping 30 seconds"
sleep 30

#Longhorn
./scripts/component.sh -c longhorn -n longhorn
kubectl apply -f ./tmp/longhorn_render.yaml -n longhorn
echo "Applied longhorn. Sleeping 60 seconds"
sleep 60

#ArgoCD
./scripts/component.sh -c argocd -n argocd
kubectl apply -f ./tmp/argocd_render.yaml -n argocd
echo "Applied argocd. Sleeping 60 seconds"
sleep 60

#Bootstrap
./scripts/component.sh -c root -n argocd
kubectl apply -f ./tmp/root_render.yaml -n argocd
echo "Applied root."
