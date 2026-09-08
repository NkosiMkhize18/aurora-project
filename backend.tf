terraform {
  backend "s3" {
    bucket       = "aurora-project-terraform-state-080185743867"
    key          = "aurora-project/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
