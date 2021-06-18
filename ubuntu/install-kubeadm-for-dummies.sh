#!/bin/bash

#
# Install kubeadm and related stuff all-at-once for dummy.
#
# References:
#   - Official K8s doc "Installing kubeadm": 
#     https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
#
#   - Udemy course "Certified Kubernetes Administrator (CKA) with Practice Tests":
#     https://www.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/learn/lecture/20666298
#
#



#
# URL: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#letting-iptables-see-bridged-traffic
#
echo "" ; echo "==> Letting iptables see bridged traffic"

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system



#
# URL: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime
# URL: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
# URL: https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
# URL: https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
#
echo "" ; echo "==> Installing runtime"

   echo "" ; echo "--> Install Docker using the convenience script"
   curl -fsSL https://get.docker.com -o get-docker.sh
   ### DRY_RUN=1 sh ./get-docker.sh
   sudo sh get-docker.sh


   echo "" ; echo "--> Configure the Docker daemon"
   sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF


   echo "" ; echo "--> Restart Docker and enable on boot"
   sudo systemctl enable docker
   sudo systemctl daemon-reload
   sudo systemctl restart docker

   echo "" ; echo "--> Manage Docker as a non-root user"
   #sudo groupadd docker
   sudo usermod -aG docker $USER
   sudo usermod -aG docker vagrant
   #newgrp - docker



#
# URL: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
#
echo "" ; echo "==> Installing kubeadm, kubelet and kubectl"

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


#
# URL: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node
#
echo "" ; echo "Run kubeadm config images pull prior to kubeadm init to verify connectivity to the gcr.io container image registry."
kubeadm config images pull



#
#
#
echo "" ; echo "==> Done."
