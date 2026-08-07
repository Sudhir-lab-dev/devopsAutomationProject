variable "aws_region" {
  description = "AWS Region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "automation-devops-project"
}

variable "environment" {
  description = "Deployment Environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type_jenkins" {
  description = "Jenkins EC2 Instance Type"
  type        = string
  default     = "c7i-flex.large"
}

variable "instance_type_app" {
  description = "Application EC2 Instance Type"
  type        = string
  default     = "c7i-flex.large"
}

variable "key_pair_name" {
  description = "AWS EC2 Key Pair Name"
  type        = string
}