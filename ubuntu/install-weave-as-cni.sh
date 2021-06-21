#!/bin/bash

#
# Installing a Pod network add-on
#
# Note: only Kubernetes doc v1.17 (and before) contains
#       step-by-step instructions for installing Weave.
#
#       URL: https://v1-17.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
#

echo "" ; echo "==> Installing Weave Net as CNI..."
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"


echo "" ; echo "Done."
