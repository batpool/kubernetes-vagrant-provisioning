#!/bin/bash

###############################################################################
# Kubernetes vagrant provisioning                                             #
#                                                                             #
# @author     :-  batpool                                                     #
#                                                                             #
# LICENSE                                                                     #
#                                                                             #
# Copyright (c) 2012 "copyright notice checker" Authors. All rights reserved. #
#                                                                             #
# Redistribution and use in source and binary forms, with or without          #
# modification, are permitted provided that the following conditions are      #
# met:                                                                        #
#                                                                             #
# * Redistributions of source code must retain the above copyright            #
# notice, this list of conditions and the following disclaimer.               #
#                                                                             #
# * Redistributions in binary form must reproduce the above                   #
# copyright notice, this list of conditions and the following disclaimer      #
# in the documentation and/or other materials provided with the               #
# distribution.                                                               #
#                                                                             #
# * None of the names of its contributors may be used to endorse              #
# or promote products derived from this software without specific             #
# prior written permission.                                                   #
#                                                                             #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS         #
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT           #
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR       #
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT        #
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,       #
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT            #
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,       #
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY       #
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT         #
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE       #
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.        #
###############################################################################




echo "[TASK 1] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 2] Stop and Disable firewall"
systemctl disable --now ufw

echo "[TASK 3] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#letting-iptables-see-bridged-traffic
echo "[TASK 4] Add Kernel settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

echo "[TASK 5] Install containerd runtime"
apt update
apt install -y containerd apt-transport-https
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd


# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
echo "[TASK 6] Add apt repo for kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

echo "[TASK 7] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt install -y kubeadm=1.22.0-00 kubelet=1.22.0-00 kubectl=1.22.0-00

echo "[TASK 8] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 9] Set root password"
echo -e "root\nroot" | passwd root
echo "export TERM=xterm" >> /etc/bash.bashrc

echo "[TASK 10] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
192.168.58.100   kmaster.batpool.com     kmaster
192.168.58.101   kworker1.batpool.com    kworker1
192.168.58.102   kworker2.batpool.com    kworker2
EOF

echo "Set authorized_keys"
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjl+f21wMKo+R3jKMiWNu9b5mbz5o3uo7XpP2Loi779JlvndxEpj3FMb336uXr6dLys/zZGMTSRMz5cvMijxpDifSfMhM744qgedMBW8L2j9Z468xxoEwaPaH24GhhwOqAnOTFw25QzE+npwBAmuT7Or4apO4a2usDaC6JkfrCdSk2huTD/6c0xlkd20zRyeLEFqwN7bqd77jPou2T5FNvbD2i24z7zNHOXW//iFcXBBiSpQ84VnJ4Io9QkUfBreUqLbWA7gl7DCJrxWYt9q8h5A2e5iVHXGYKE6ibcCBLLUhK2cp42NiwdPK79gdI366kn4mD5EcI9xKO1p8Jqt2F root@heisenberg" >> /root/.ssh/authorized_keys
