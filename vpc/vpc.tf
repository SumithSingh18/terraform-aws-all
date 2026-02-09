module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.2.0" # Clean version for stability

  namespace   = local.stage
  stage       = ""
  name        = local.name
  
  ipv4_primary_cidr_block = var.vpc_cidr

  tags = local.tags
}

# -------------------------------------------------------------------------
# VPC Flow Logs Configuration
# SOW Requirement: Enable VPC Flow Logs with an S3 bucket as the destination.
# -------------------------------------------------------------------------

resource "aws_s3_bucket" "flow_logs" {
  bucket_prefix = "${local.stage}-mb-flow-logs-"
  force_destroy = true 
  tags          = local.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    id     = "expire-logs"
    status = "Enabled"
    expiration {
      days = 90
    }
  }
}

resource "aws_flow_log" "main" {
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = module.vpc.vpc_id
  
  tags = merge(local.tags, { Name = "${local.stage}-mb-flow-log" })
}
