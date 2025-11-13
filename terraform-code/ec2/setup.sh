#!/bin/bash
set -euxo pipefail

# Update
apt-get update -y
apt-get install -y unzip curl wget gnupg apt-transport-https ca-certificates software-properties-common

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

# SonarQube container
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# Trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | tee /etc/apt/sources.list.d/trivy.list
apt-get update -y
apt-get install -y trivy

# Kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.4/2024-09-11/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/
kubectl version --client

# Helm
wget https://get.helm.sh/helm-v3.16.1-linux-amd64.tar.gz
tar -zxvf helm-v3.16.1-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm

# ArgoCD
VERSION=$(curl -sL https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v${VERSION}/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# Java 17
apt-get install -y openjdk-17-jdk openjdk-17-jre

# Jenkins
wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list
apt-get update -y
apt-get install -y jenkins
systemctl enable jenkins
systemctl start jenkins

# Output info
IP=$(curl -s ifconfig.me)
PASS=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword || echo "Password file not ready yet")

echo "Access Jenkins:  http://$IP:8080"
echo "Initial Jenkins password: $PASS"
echo "Access SonarQube: http://$IP:9000 (admin/admin)"
