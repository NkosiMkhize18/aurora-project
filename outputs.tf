output "vpc_id" {
  description = "ID of the Aurora VPC."
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

output "aurora_cluster_endpoint" {
  description = "Writer endpoint for the Aurora cluster."
  value       = aws_rds_cluster.aurora.endpoint
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint for the Aurora cluster."
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "aurora_port" {
  description = "Port the Aurora cluster listens on."
  value       = aws_rds_cluster.aurora.port
}

output "aurora_database_name" {
  description = "Name of the Aurora database."
  value       = aws_rds_cluster.aurora.database_name
}

output "aurora_secret_arn" {
  description = "ARN of the Secrets Manager secret holding Aurora master credentials."
  value       = aws_secretsmanager_secret.aurora_master.arn
}

output "aurora_security_group_id" {
  description = "Security group ID of the Aurora cluster."
  value       = aws_security_group.aurora.id
}

output "eks_db_client_security_group_id" {
  description = "Attach this SG to EKS nodes/pods to allow Aurora access."
  value       = aws_security_group.eks_db_client.id
}

output "ssm_bastion_instance_id" {
  description = "Instance ID of the SSM bastion for human port-forwarding to Aurora."
  value       = aws_instance.ssm_bastion.id
}

output "eks_aurora_iam_role_arn" {
  description = "ARN of the IRSA role EKS pods annotate their service account with to get Aurora IAM auth."
  value       = aws_iam_role.eks_aurora_access.arn
}

output "human_aurora_iam_policy_arn" {
  description = "ARN of the IAM policy to attach to human IAM users/roles for Aurora IAM auth."
  value       = aws_iam_policy.human_aurora_iam_auth.arn
}
