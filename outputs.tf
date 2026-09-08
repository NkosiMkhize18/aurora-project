output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "availability_zones" {
  description = "Availability zones used by the private subnets."
  value       = aws_subnet.private[*].availability_zone
}

# -------------------------
# Aurora outputs (enable_aurora = true)
# -------------------------
output "aurora_cluster_endpoint" {
  description = "Writer endpoint for the Aurora cluster."
  value       = var.enable_aurora ? aws_rds_cluster.aurora[0].endpoint : null
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint for the Aurora cluster."
  value       = var.enable_aurora ? aws_rds_cluster.aurora[0].reader_endpoint : null
}

output "aurora_port" {
  description = "Port the Aurora cluster listens on."
  value       = var.enable_aurora ? aws_rds_cluster.aurora[0].port : null
}

output "aurora_secret_arn" {
  description = "ARN of the Secrets Manager secret holding Aurora master credentials."
  value       = var.enable_aurora ? aws_secretsmanager_secret.aurora_master[0].arn : null
}

output "aurora_security_group_id" {
  description = "Security group ID for database access."
  value       = aws_security_group.aurora.id
}

output "eks_db_client_security_group_id" {
  description = "Attach this SG to EKS nodes/pods to allow database access."
  value       = aws_security_group.eks_db_client.id
}

output "ssm_bastion_instance_id" {
  description = "Instance ID of the SSM bastion for human port-forwarding to Aurora."
  value       = var.enable_aurora ? aws_instance.ssm_bastion[0].id : null
}

output "human_aurora_iam_policy_arn" {
  description = "ARN of the IAM policy for human Aurora IAM auth."
  value       = var.enable_aurora ? aws_iam_policy.human_aurora_iam_auth[0].arn : null
}

# -------------------------
# Free tier RDS outputs (enable_rds_free_tier = true)
# -------------------------
output "rds_free_tier_endpoint" {
  description = "Endpoint for the free tier RDS PostgreSQL instance."
  value       = var.enable_rds_free_tier ? aws_db_instance.free_tier[0].address : null
}

output "rds_free_tier_port" {
  description = "Port for the free tier RDS PostgreSQL instance."
  value       = var.enable_rds_free_tier ? aws_db_instance.free_tier[0].port : null
}

output "human_rds_iam_policy_arn" {
  description = "ARN of the IAM policy for human free tier RDS IAM auth."
  value       = var.enable_rds_free_tier ? aws_iam_policy.human_rds_free_tier_iam_auth[0].arn : null
}
