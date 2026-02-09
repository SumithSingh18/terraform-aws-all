resource "aws_security_group" "app_sg" {
  name        = "${local.stage}-mb-app-sg"
  description = "Security Group for Application Layer"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.tags,
    {
      Name  = "${local.stage}-mb-app-sg"
      Layer = "App"
    }
  )
}

resource "aws_security_group" "db_sg" {
  name        = "${local.stage}-mb-db-sg"
  description = "Security Group for Database Layer"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.tags,
    {
      Name  = "${local.stage}-mb-db-sg"
      Layer = "Database"
    }
  )
}

# Example Rule: Allow App to talk to DB
resource "aws_security_group_rule" "app_to_db" {
  type                     = "ingress"
  from_port                = 5432 # Postgres/Aurora
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.db_sg.id
  description              = "Allow App to reach Database"
}
