data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name = "${var.project_name}-github-oidc"
  }
}

data "aws_iam_policy_document" "github_plan_assume_role" {
  statement {
    sid     = "GitHubActionsOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:NkosiMkhize18@19518913/aurora-project@1360545813:pull_request"
      ]

    }
  }
}

data "aws_iam_policy_document" "github_apply_assume_role" {
  statement {
    sid     = "GitHubActionsOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:NkosiMkhize18@19518913/aurora-project@1360545813:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "github_plan" {
  name = "${var.project_name}-github-plan"

  assume_role_policy = data.aws_iam_policy_document.github_plan_assume_role.json

  description = "Terraform plan role for GitHub Actions."

  tags = {
    Name = "${var.project_name}-github-plan"
  }
}

resource "aws_iam_role" "github_apply" {
  name = "${var.project_name}-github-apply"

  assume_role_policy = data.aws_iam_policy_document.github_apply_assume_role.json

  description = "Terraform apply role for GitHub Actions."

  tags = {
    Name = "${var.project_name}-github-apply"
  }
}

data "aws_iam_policy_document" "terraform_state_plan" {
  statement {
    sid    = "ListTerraformState"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.terraform_state.arn
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "aurora-project/*"
      ]
    }
  }

  statement {
    sid    = "ReadTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.terraform_state.arn}/aurora-project/terraform.tfstate"
    ]
  }

  statement {
    sid    = "ManageTerraformStateLock"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.terraform_state.arn}/aurora-project/terraform.tfstate.tflock"
    ]
  }
}

data "aws_iam_policy_document" "github_plan_readonly" {
  statement {
    sid    = "ReadEC2"
    effect = "Allow"

    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeRouteTables",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNatGateways",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeTags"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_plan_readonly" {
  name = "${var.project_name}-github-plan-readonly"

  role = aws_iam_role.github_plan.id

  policy = data.aws_iam_policy_document.github_plan_readonly.json
}

resource "aws_iam_role_policy" "github_apply_readonly" {
  name = "${var.project_name}-github-apply-readonly"

  role = aws_iam_role.github_apply.id

  policy = data.aws_iam_policy_document.github_plan_readonly.json
}

data "aws_iam_policy_document" "terraform_state_apply" {
  statement {
    sid    = "ListTerraformState"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.terraform_state.arn
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "aurora-project/*"
      ]
    }
  }

  statement {
    sid    = "ManageTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.terraform_state.arn}/aurora-project/terraform.tfstate"
    ]
  }

  statement {
    sid    = "ManageTerraformStateLock"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.terraform_state.arn}/aurora-project/terraform.tfstate.tflock"
    ]
  }
}

resource "aws_iam_role_policy" "github_plan_state" {
  name = "${var.project_name}-github-plan-state"

  role = aws_iam_role.github_plan.id

  policy = data.aws_iam_policy_document.terraform_state_plan.json
}

resource "aws_iam_role_policy" "github_apply_state" {
  name = "${var.project_name}-github-apply-state"

  role = aws_iam_role.github_apply.id

  policy = data.aws_iam_policy_document.terraform_state_apply.json
}


