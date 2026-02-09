locals {
  enabled     = true
  namespace   = var.project
  environment = var.environment
  stage       = var.environment
  name        = "mb" # Base name for the VPC related resources

  tags = {
    Project     = "Kgen"
    Environment = title(var.environment) # e.g. Staging
    ManagedBy   = "Terraform"
  }
}
