#########################################
# Application EC2 Instance
#########################################

resource "aws_instance" "application" {

  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type_app
  key_name             = var.key_pair_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  subnet_id            = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  associate_public_ip_address = true

  user_data = file("${path.module}/user-data/app.sh")

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-application"
    }
  )
}

#########################################
# Elastic IP
#########################################

resource "aws_eip" "application_eip" {

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-application-eip"
    }
  )
}

#########################################
# Associate Elastic IP
#########################################

resource "aws_eip_association" "application" {

  instance_id   = aws_instance.application.id
  allocation_id = aws_eip.application_eip.id
}