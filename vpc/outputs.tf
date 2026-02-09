output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "VPC CIDR Block"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "List of Public Subnet IDs"
}

output "app_private_subnet_ids" {
  value       = aws_subnet.app_private[*].id
  description = "List of App Private Subnet IDs"
}

output "db_private_subnet_ids" {
  value       = aws_subnet.db_private[*].id
  description = "List of DB Private Subnet IDs"
}

output "nat_gateway_ids" {
  value       = aws_nat_gateway.main[*].id
  description = "List of NAT Gateway IDs"
}

output "app_security_group_id" {
  value       = aws_security_group.app_sg.id
  description = "Security Group ID for Application Layer"
}

output "db_security_group_id" {
  value       = aws_security_group.db_sg.id
  description = "Security Group ID for Database Layer"
}
