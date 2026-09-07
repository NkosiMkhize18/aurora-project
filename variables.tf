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
