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

#########################################
# S3 Outputs
#########################################

output "screenshots_bucket_name" {

  description = "S3 bucket used for automation screenshots"

  value = aws_s3_bucket.screenshots.bucket
}


output "screenshots_bucket_arn" {

  description = "ARN of the screenshot S3 bucket"

  value = aws_s3_bucket.screenshots.arn
}