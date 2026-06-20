terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # AWS credentials are intentionally not declared here.
  # In AWS Academy, Terraform should read AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY,
  # and AWS_SESSION_TOKEN from the shell environment.
  # The region stays configurable so the same sample can be reused across lab accounts.
  region = var.aws_region
}
