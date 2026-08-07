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
# Custom ECR Read Policy
#########################################

resource "aws_iam_policy" "ecr_pull_policy" {

  name = "${var.project_name}-ecr-pull-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages"
        ]

        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-ecr-pull-policy"
    }
  )
}

#########################################
# Attach Policy
#########################################

resource "aws_iam_role_policy_attachment" "ecr_pull_attach" {

  role = aws_iam_role.ec2_role.name

  policy_arn = aws_iam_policy.ecr_pull_policy.arn
}

#########################################
# Instance Profile
#########################################

resource "aws_iam_instance_profile" "ec2_profile" {

  name = "${var.project_name}-ec2-profile"

  role = aws_iam_role.ec2_role.name
}
