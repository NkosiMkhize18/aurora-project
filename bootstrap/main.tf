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
        "repo:${var.github_repository}:pull_request"
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
        "repo:${var.github_repository}:ref:refs/heads/main"
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
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeTags"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ReadRDS"
    effect = "Allow"

    actions = [
      "rds:DescribeDBSubnetGroups",
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "rds:ListTagsForResource"
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

data "aws_iam_policy_document" "github_apply_vpc" {
  statement {
    sid    = "ManageVPC"
    effect = "Allow"

    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:ModifyVpcAttribute",
      "ec2:CreateInternetGateway",
      "ec2:CreateSubnet",
      "ec2:CreateRouteTable",
      "ec2:CreateRoute",
      "ec2:CreateTags",
      "ec2:AttachInternetGateway",
      "ec2:AssociateRouteTable",
      "ec2:ModifySubnetAttribute",
      "ec2:DeleteRoute",
      "ec2:DetachInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteSubnet",
      "ec2:DeleteRouteTable"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_apply_vpc" {
  name = "${var.project_name}-github-apply-vpc"

  role = aws_iam_role.github_apply.id

  policy = data.aws_iam_policy_document.github_apply_vpc.json
}

data "aws_iam_policy_document" "github_apply_security_groups" {
  statement {
    sid    = "ManageSecurityGroups"
    effect = "Allow"

    actions = [
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_apply_security_groups" {
  name = "${var.project_name}-github-apply-security-groups"

  role = aws_iam_role.github_apply.id

  policy = data.aws_iam_policy_document.github_apply_security_groups.json
}

data "aws_iam_policy_document" "github_apply_rds" {
  statement {
    sid    = "ManageRDS"
    effect = "Allow"

    actions = [
      "rds:CreateDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",
      "rds:ModifyDBSubnetGroup",
      "rds:AddTagsToResource",
      "rds:RemoveTagsFromResource",
      "rds:CreateDBCluster",
      "rds:DeleteDBCluster",
      "rds:ModifyDBCluster",
      "rds:CreateDBInstance",
      "rds:DeleteDBInstance",
      "rds:ModifyDBInstance"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_apply_rds" {
  name = "${var.project_name}-github-apply-rds"

  role = aws_iam_role.github_apply.id

  policy = data.aws_iam_policy_document.github_apply_rds.json
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


