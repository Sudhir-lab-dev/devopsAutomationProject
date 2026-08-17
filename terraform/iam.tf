#########################################
# EC2 Assume Role Policy
#########################################

data "aws_iam_policy_document" "ec2_assume_role" {

  statement {

    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


#########################################
# IAM Role
#########################################

resource "aws_iam_role" "ec2_role" {

  name = "${var.project_name}-ec2-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-ec2-role"
    }
  )
}


#########################################
# ECR Policy - Pull + Push
#########################################

resource "aws_iam_policy" "ecr_policy" {

  name = "${var.project_name}-ecr-policy"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        # ECR authentication
        # Repository read/pull
        # Repository push
        Action = [

          # Authentication
          "ecr:GetAuthorizationToken",

          # Pull / Read
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",

          # Push
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]

        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-ecr-policy"
    }
  )
}


#########################################
# Attach ECR Policy to EC2 Role
#########################################

resource "aws_iam_role_policy_attachment" "ecr_attach" {

  role = aws_iam_role.ec2_role.name

  policy_arn = aws_iam_policy.ecr_policy.arn
}


#########################################
# Instance Profile
#########################################

resource "aws_iam_instance_profile" "ec2_profile" {

  name = "${var.project_name}-ec2-profile"

  role = aws_iam_role.ec2_role.name
}

#########################################
# S3 Screenshot Policy
#########################################

resource "aws_iam_policy" "s3_screenshot_policy" {
  name = "automation-devops-project-s3-screenshot-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.screenshots.arn
      },
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]

        Resource = "${aws_s3_bucket.screenshots.arn}/*"
      }
    ]
  })

  tags = {
    Name        = "automation-devops-project-s3-screenshot-policy"
    Project     = "automation-devops-project"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Sudhir"
  }
}


#########################################
# Attach S3 Policy to EC2 Role
#########################################

resource "aws_iam_role_policy_attachment" "s3_screenshot_attach" {

  role = aws_iam_role.ec2_role.name

  policy_arn = aws_iam_policy.s3_screenshot_policy.arn
}

#########################################
# EKS Access Policy for Jenkins
#########################################

resource "aws_iam_policy" "jenkins_eks_policy" {

  name = "${var.project_name}-jenkins-eks-policy"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "eks:DescribeCluster"
        ]

        Resource = aws_eks_cluster.main.arn
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-jenkins-eks-policy"
    }
  )
}


#########################################
# Attach EKS Policy to EC2 Role
#########################################

resource "aws_iam_role_policy_attachment" "jenkins_eks_attach" {

  role = aws_iam_role.ec2_role.name

  policy_arn = aws_iam_policy.jenkins_eks_policy.arn
}