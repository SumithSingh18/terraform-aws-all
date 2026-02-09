# Public Subnets (2) - For ALB, NAT Gateways
resource "aws_subnet" "public" {
  count = 2

  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, 6, count.index) # 10.1.0.0/22, 10.1.4.0/22
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name                     = "${local.stage}-mb-pub-subnet0${count.index + 1}"
      Type                     = "Public"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.stage}-mb-pub-rt"
    }
  )
}

# Public Route to Internet
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc.igw_id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateways (one per AZ)
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

  tags = merge(
    local.tags,
    {
      Name = "${local.stage}-mb-nat-eip-${var.availability_zones[count.index]}"
    }
  )

  depends_on = [module.vpc]
}

resource "aws_nat_gateway" "main" {
  count = 2

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.tags,
    {
      Name = "${local.stage}-mb-nat-${var.availability_zones[count.index]}"
    }
  )

  depends_on = [module.vpc]
}

# Private App Subnets (2) - For EKS workloads
resource "aws_subnet" "app_private" {
  count = 2

  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, 6, count.index + 2) # 10.1.8.0/22, 10.1.12.0/22
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.tags,
    {
      Name                              = "${local.stage}-app-mb-pri-subnet0${count.index + 1}"
      Type                              = "Private"
      Layer                             = "App"
      "kubernetes.io/role/internal-elb" = "1"
      "karpenter.sh/discovery"          = "${local.stage}-mb-cluster"
    }
  )
}

# Private App Route Tables (one per AZ for NAT)
resource "aws_route_table" "app_private" {
  count = 2

  vpc_id = module.vpc.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.stage}-app-mb-pri-rt-${var.availability_zones[count.index]}"
    }
  )
}

# Private App Routes to NAT Gateway
resource "aws_route" "app_private_nat" {
  count = 2

  route_table_id         = aws_route_table.app_private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# Associate App Subnets with App Route Tables
resource "aws_route_table_association" "app_private" {
  count = 2

  subnet_id      = aws_subnet.app_private[count.index].id
  route_table_id = aws_route_table.app_private[count.index].id
}

# Private DB Subnets (2) - Isolated, no internet access
resource "aws_subnet" "db_private" {
  count = 2

  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, 6, count.index + 4) # 10.1.16.0/22, 10.1.20.0/22
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.tags,
    {
      Name  = "${local.stage}-db-mb-pri-subnet0${count.index + 1}"
      Type  = "Private"
      Layer = "Database"
    }
  )
}

# Private DB Route Table (isolated, no NAT)
resource "aws_route_table" "db_private" {
  vpc_id = module.vpc.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.stage}-db-mb-pri-rt"
    }
  )
}

# Associate DB Subnets with DB Route Table
resource "aws_route_table_association" "db_private" {
  count = 2

  subnet_id      = aws_subnet.db_private[count.index].id
  route_table_id = aws_route_table.db_private.id
}
