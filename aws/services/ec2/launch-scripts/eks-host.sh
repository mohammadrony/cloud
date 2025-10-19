#!/bin/bash
# EKS Management Host

apt update; apt -y upgrade

# Set hostname
echo 'ekshost' > /etc/hostname

# Install kubectl
curl -LO "https://dl.k8s.io/release/v1.27.0/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/

# Install eksctl
curl --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz --directory /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Install awscli
curl --output "awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o install.sh
bash install.sh
rm -f install.sh

# Add Helm charts
helm repo add eks https://aws.github.io/eks-charts

# Add kubectl alias
echo 'alias k="kubectl"' > ~ec2-user/.bashrc

reboot now
