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

