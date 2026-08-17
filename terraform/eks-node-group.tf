# ==========================================
# EKS MANAGED NODE GROUP
# ==========================================

resource "aws_eks_node_group" "main" {
  cluster_name = aws_eks_cluster.main.name

  node_group_name = "${var.project_name}-node-group"

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = [
    aws_subnet.eks_private_1.id,
    aws_subnet.eks_private_2.id
  ]

  instance_types = ["c7i-flex.large"]

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.project_name}-eks-node-group"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_only
  ]
}