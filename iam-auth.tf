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

# -------------------------
# Human IAM auth policy
# Attach to IAM users/roles that need direct DB access via SSM port-forward
# -------------------------
resource "aws_iam_policy" "human_aurora_iam_auth" {
  name        = "${var.project_name}-human-aurora-iam-auth"
  description = "Attach to IAM users/roles that need IAM auth access to Aurora via SSM port-forwarding."

  policy = data.aws_iam_policy_document.aurora_iam_auth.json

  tags = {
    Name = "${var.project_name}-human-aurora-iam-auth"
  }
}
