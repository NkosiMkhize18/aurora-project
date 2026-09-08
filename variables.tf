variable "aws_region" {
  description = "AWS region where the Aurora environment will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used to identify project resources."
  type        = string
  default     = "aurora-project"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "eks_oidc_provider_arn" {
  description = "ARN of the EKS cluster OIDC provider for IRSA."
  type        = string
}

variable "eks_oidc_provider_url" {
  description = "URL of the EKS cluster OIDC provider (without https://)."
  type        = string
}

variable "eks_db_service_accounts" {
  description = "List of K8s service accounts allowed to assume the Aurora IAM auth role. Format: 'namespace:serviceaccount'."
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "Name of the Aurora PostgreSQL database."
  type        = string
  default     = "appdb"
}

variable "db_master_username" {
  description = "Master username for Aurora PostgreSQL."
  type        = string
  default     = "dbadmin"
}

variable "db_master_password" {
  description = "Master password for Aurora PostgreSQL. Supply via TF_VAR or Secrets Manager — never hardcode."
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Tags applied to all supported AWS resources."
  type        = map(string)

  default = {
    Project     = "aurora-project"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
    CostCenter  = "personal"
  }
}

