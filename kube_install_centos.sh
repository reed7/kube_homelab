#!/bin/bash

# For installing docker and kube on amd64 CentOS7 machines
# - Install Docker
# - Open ports on firewall
# - Install Kube
# - Change SELINUX settings
# - Change network settings
#
# This script doesn't take care of disabling swap, you need to do that manually:
# - swapoff -a
# - Remove the entry on /etc/fstab
# - Reboot

curl -fsSL https://get.docker.com/ | sh

systemctl start docker

systemctl enable docker

firewall-cmd --add-port 6443/tcp --permanent
firewall-cmd --add-port 2379-2380/tcp --permanent
firewall-cmd --add-port 10250-10252/tcp --permanent
#Weave
firewall-cmd --add-port 6783/tcp --add-port 6783/udp --add-port 6784/udp --permanent
#Flannel
#firewall-cmd --add-port 8285/udp --add-port 8472/udp --permanent

systemctl restart firewalld

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable kubelet && systemctl start kubelet

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
