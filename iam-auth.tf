data "aws_iam_policy_document" "aurora_iam_auth" {
  statement {
    sid    = "AllowIAMDatabaseAuthentication"
    effect = "Allow"

    actions = ["rds-db:connect"]

    resources = [
      "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.aurora.cluster_resource_id}/*"
    ]
  }
}

resource "aws_iam_policy" "aurora_iam_auth" {
  name        = "${var.project_name}-aurora-iam-auth"
  description = "Allows IAM authentication to the Aurora PostgreSQL cluster."

  policy = data.aws_iam_policy_document.aurora_iam_auth.json

  tags = {
    Name = "${var.project_name}-aurora-iam-auth"
  }
}

# -------------------------
# EKS pod IAM auth via IRSA
# Each microservice gets its own role scoped to its K8s service account
# -------------------------
data "aws_iam_policy_document" "eks_pod_aurora_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.eks_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_provider_url}:sub"
      values   = [for sa in var.eks_db_service_accounts : "system:serviceaccount:${sa}"]
    }
  }
}

resource "aws_iam_role" "eks_aurora_access" {
  name        = "${var.project_name}-eks-aurora-access"
  description = "Assumed by EKS pods via IRSA to authenticate to Aurora using IAM."

  assume_role_policy = data.aws_iam_policy_document.eks_pod_aurora_assume.json

  tags = {
    Name = "${var.project_name}-eks-aurora-access"
  }
}

resource "aws_iam_role_policy_attachment" "eks_aurora_iam_auth" {
  role       = aws_iam_role.eks_aurora_access.name
  policy_arn = aws_iam_policy.aurora_iam_auth.arn
}

# -------------------------
# Human IAM auth policy
# Attach this to IAM users/roles that need direct DB access via SSM port-forward
# -------------------------
resource "aws_iam_policy" "human_aurora_iam_auth" {
  name        = "${var.project_name}-human-aurora-iam-auth"
  description = "Attach to IAM users/roles that need IAM auth access to Aurora via SSM port-forwarding."

  policy = data.aws_iam_policy_document.aurora_iam_auth.json

  tags = {
    Name = "${var.project_name}-human-aurora-iam-auth"
  }
}
