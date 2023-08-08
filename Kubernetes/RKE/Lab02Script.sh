#!/bin/bash

# Create and edit the rke2-canal.conf file
sudo bash -c "cat > /etc/NetworkManager/conf.d/rke2-canal.conf <<EOF
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:flannel*
EOF"

# Reload NetworkManager
sudo systemctl reload NetworkManager

# Edit the hosts file
sudo bash -c "cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.16.7.51 stud7-s1 stud7-s1.stud7.soroc.mil
172.16.7.50 vip vip.stud7.soroc.mil
EOF"

# Edit the bashrc file
sudo bash -c "cat >> /root/.bashrc <<EOF
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export PATH=$PATH:/var/lib/rancher/rke2/bin:/usr/local/bin
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
alias ku=kubectl
alias kuebctl=kubectl
alias k=kubectl
EOF"

# Source the bashrc file
source /root/.bashrc

# Edit the SELinux configuration file
sudo bash -c "cat > /etc/selinux/config <<EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF"

# Set SELinux to permissive mode
sudo setenforce permissive

# Check SELinux status
getenforce

# Disable firewalld
sudo systemctl disable firewalld --now

