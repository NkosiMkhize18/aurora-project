output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_plan_role_arn" {
  description = "ARN of the GitHub Actions Terraform plan role."
  value       = aws_iam_role.github_plan.arn
}

output "github_apply_role_arn" {
  description = "ARN of the GitHub Actions Terraform apply role."
  value       = aws_iam_role.github_apply.arn
}

output "aws_account_id" {
  description = "AWS account ID used by the bootstrap."
  value       = data.aws_caller_identity.current.account_id
}
