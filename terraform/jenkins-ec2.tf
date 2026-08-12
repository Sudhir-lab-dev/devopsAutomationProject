#########################################
# Jenkins EC2 Instance
#########################################

resource "aws_instance" "jenkins" {

  ami                  = "ami-0bdc7d025135d7b49"
  instance_type        = var.instance_type_jenkins
  key_name             = var.key_pair_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id
  ]

  associate_public_ip_address = true

  user_data = file("${path.module}/user-data/jenkins.sh")

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-jenkins"
    }
  )
}

#########################################
# Elastic IP
#########################################

resource "aws_eip" "jenkins_eip" {

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-jenkins-eip"
    }
  )
}

#########################################
# Associate Elastic IP
#########################################

resource "aws_eip_association" "jenkins" {

  instance_id   = aws_instance.jenkins.id
  allocation_id = aws_eip.jenkins_eip.id
}
