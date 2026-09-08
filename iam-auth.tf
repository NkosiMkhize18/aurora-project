# -------------------------
# Aurora IAM auth
# -------------------------
data "aws_iam_policy_document" "aurora_iam_auth" {
  count = var.enable_aurora ? 1 : 0

  statement {
    sid     = "AllowIAMDatabaseAuthentication"
    effect  = "Allow"
    actions = ["rds-db:connect"]

    resources = [
      "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.aurora[0].cluster_resource_id}/*"
    ]
  }
}

resource "aws_iam_policy" "human_aurora_iam_auth" {
  count = var.enable_aurora ? 1 : 0

  name        = "${var.project_name}-human-aurora-iam-auth"
  description = "Attach to IAM users/roles that need IAM auth access to Aurora via SSM port-forwarding."
  policy      = data.aws_iam_policy_document.aurora_iam_auth[0].json

  tags = {
    Name = "${var.project_name}-human-aurora-iam-auth"
  }
}

# -------------------------
# Free tier RDS IAM auth
# -------------------------
data "aws_iam_policy_document" "rds_free_tier_iam_auth" {
  count = var.enable_rds_free_tier ? 1 : 0

  statement {
    sid     = "AllowIAMDatabaseAuthentication"
    effect  = "Allow"
    actions = ["rds-db:connect"]

    resources = [
      "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.free_tier[0].resource_id}/*"
    ]
  }
}

resource "aws_iam_policy" "human_rds_free_tier_iam_auth" {
  count = var.enable_rds_free_tier ? 1 : 0

  name        = "${var.project_name}-human-rds-iam-auth"
  description = "Attach to IAM users/roles that need IAM auth access to the free tier RDS instance."
  policy      = data.aws_iam_policy_document.rds_free_tier_iam_auth[0].json

  tags = {
    Name = "${var.project_name}-human-rds-iam-auth"
  }
}
