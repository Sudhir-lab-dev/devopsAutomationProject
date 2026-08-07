#!/bin/bash

dnf update -y

# Java
dnf install java-21-amazon-corretto -y

# Git
dnf install git -y

# Docker
dnf install docker -y

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

# AWS CLI
dnf install awscli -y

# NodeJS 22
curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
dnf install nodejs -y

# Jenkins
wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

dnf install jenkins -y

systemctl enable jenkins
systemctl start jenkins