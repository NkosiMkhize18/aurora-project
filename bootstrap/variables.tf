variable "aws_region" {
  description = "AWS region for bootstrap resources."
  type        = string
  default     = "us-east-1"
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the deployment role."
  type        = string
  default     = "NkosiMkhize18/aurora-project"
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "aurora-project"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "terraform_state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string
  default     = "aurora-project-terraform-state-080185743867"
}

