resource "aws_eks_cluster" "main" {
  name = "${var.project_name}-eks"

  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_private_1.id,
      aws_subnet.eks_private_2.id
    ]

    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = "${var.project_name}-eks"
  }
}