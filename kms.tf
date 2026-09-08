data "aws_caller_identity" "current" {}

resource "aws_kms_key" "aurora" {
  description             = "KMS key for Aurora PostgreSQL encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_aurora.json

  tags = {
    Name = "${var.project_name}-aurora-kms"
  }
}

resource "aws_kms_alias" "aurora" {
  name          = "alias/${var.project_name}-aurora"
  target_key_id = aws_kms_key.aurora.key_id
}

data "aws_iam_policy_document" "kms_aurora" {
  statement {
    sid    = "RootAccountFullAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "RDSServiceAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "SecretsManagerAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["secretsmanager.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]

    resources = ["*"]
  }
}
