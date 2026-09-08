resource "aws_db_subnet_group" "free_tier" {
  count = var.enable_rds_free_tier ? 1 : 0

  name       = "${var.project_name}-free-tier"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-free-tier"
  }
}

resource "aws_db_instance" "free_tier" {
  count = var.enable_rds_free_tier ? 1 : 0

  identifier = "${var.project_name}-free-tier"

  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = false

  db_name  = var.db_name
  username = var.db_master_username
  password = var.db_master_password

  db_subnet_group_name   = aws_db_subnet_group.free_tier[0].name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  iam_database_authentication_enabled = true

  backup_retention_period  = 7
  preferred_backup_window  = "02:00-03:00"
  maintenance_window       = "sun:04:00-sun:05:00"

  deletion_protection     = false
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.project_name}-free-tier"
  }
}
