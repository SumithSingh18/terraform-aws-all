# VPC Peering with MongoDB Atlas
# Note: This requires the MongoDB Atlas AWS Account ID and VPC ID to be known.

resource "aws_vpc_peering_connection" "atlas" {
  count = var.atlas_vpc_id != "" ? 1 : 0

  vpc_id        = module.vpc.vpc_id
  peer_vpc_id   = var.atlas_vpc_id
  peer_owner_id = var.atlas_aws_account_id
  peer_region   = var.region

  tags = merge(
    local.tags,
    {
      Name = "${local.stage}-mb-atlas-peering"
    }
  )
}

# Routes for Atlas Peering - Add to App Private Route Tables
resource "aws_route" "app_private_to_atlas" {
  count = var.atlas_vpc_id != "" ? 2 : 0

  route_table_id            = aws_route_table.app_private[count.index].id
  destination_cidr_block    = var.atlas_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.atlas[0].id
}

# Routes for Atlas Peering - Add to DB Private Route Table
resource "aws_route" "db_private_to_atlas" {
  count = var.atlas_vpc_id != "" ? 1 : 0

  route_table_id            = aws_route_table.db_private.id
  destination_cidr_block    = var.atlas_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.atlas[0].id
}
