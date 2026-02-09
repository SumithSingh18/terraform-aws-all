variable "region" {
  type        = string
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., staging, prod)"
  default     = "staging"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "kgen"
}


variable "profile" {
  type        = string
  description = "AWS Profile name to use for authentication"
  default     = null
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.1.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr value must be a valid CIDR block."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones"
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "atlas_project_id" {
  type        = string
  description = "MongoDB Atlas Project ID"
  default     = "" # To be provided by user or retrieved from Secrets Manager
}

variable "atlas_vpc_cidr" {
  type        = string
  description = "MongoDB Atlas VPC CIDR for peering"
  default     = "192.168.0.0/21" # Example, needs to be verified
}

variable "atlas_aws_account_id" {
  type        = string
  description = "AWS Account ID of the MongoDB Atlas VPC"
  default     = ""
}

variable "atlas_vpc_id" {
  type        = string
  description = "VPC ID of the MongoDB Atlas VPC"
  default     = ""
}
