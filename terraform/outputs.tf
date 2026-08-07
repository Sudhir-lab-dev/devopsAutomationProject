#########################################
# Jenkins Outputs
#########################################

output "jenkins_public_ip" {
  description = "Jenkins Server Public IP"
  value       = aws_eip.jenkins_eip.public_ip
}

output "jenkins_public_dns" {
  description = "Jenkins Server Public DNS"
  value       = aws_instance.jenkins.public_dns
}

#########################################
# Application Outputs
#########################################

output "application_public_ip" {
  description = "Application Server Public IP"
  value       = aws_eip.application_eip.public_ip
}

output "application_public_dns" {
  description = "Application Server Public DNS"
  value       = aws_instance.application.public_dns
}

#########################################
# Networking Outputs
#########################################

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}