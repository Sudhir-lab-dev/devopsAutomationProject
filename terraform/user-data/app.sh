#!/bin/bash

dnf update -y

# Docker
dnf install docker -y

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

# Git
dnf install git -y

# AWS CLI
dnf install awscli -y

# Nginx
dnf install nginx -y

systemctl enable nginx
systemctl start nginx