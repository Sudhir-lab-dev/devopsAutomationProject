# ==========================================
# EKS POD IDENTITY IAM ROLE
# ==========================================

resource "aws_iam_role" "automation_pod_role" {
  name = "${var.project_name}-automation-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-automation-pod-role"
  }
}

# ==========================================
# ATTACH EXISTING S3 SCREENSHOT POLICY
# ==========================================

resource "aws_iam_role_policy_attachment" "automation_pod_s3" {
  role       = aws_iam_role.automation_pod_role.name
  policy_arn = aws_iam_policy.s3_screenshot_policy.arn
}

# ==========================================
# KUBERNETES SERVICE ACCOUNT
# ==========================================

resource "kubernetes_service_account" "automation_app" {
  metadata {
    name      = "automation-app"
    namespace = "default"
  }

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_iam_role.automation_pod_role
  ]
}

# ==========================================
# EKS POD IDENTITY ASSOCIATION
# ==========================================

resource "aws_eks_pod_identity_association" "automation_app" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "default"
  service_account = kubernetes_service_account.automation_app.metadata[0].name
  role_arn        = aws_iam_role.automation_pod_role.arn

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_iam_role_policy_attachment.automation_pod_s3
  ]
}