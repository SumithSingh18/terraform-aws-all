terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "kgen-terraform-state-20260209081354290000000001"    # REPLACE WITH YOUR BUCKET NAME
    key            = "vpc/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "kgen-terraform-lock"     # REPLACE WITH YOUR DYNAMODB TABLE
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}
