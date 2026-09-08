resource "aws_db_subnet_group" "aurora" {
  name = "${var.project_name}-aurora"

  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-aurora"
  }
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  name   = "${var.project_name}-aurora-pg"
  family = "aurora-postgresql16"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Name = "${var.project_name}-aurora-pg"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${var.project_name}-aurora"

  engine         = "aurora-postgresql"
  engine_version = "16.6"

  database_name   = var.db_name
  master_username = var.db_master_username
  master_password = var.db_master_password

  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  vpc_security_group_ids          = [aws_security_group.aurora.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name

  storage_encrypted = true
  kms_key_id        = aws_kms_key.aurora.arn

  backup_retention_period = 7
  preferred_backup_window = "02:00-03:00"

  preferred_maintenance_window = "sun:04:00-sun:05:00"

  iam_database_authentication_enabled = true

  deletion_protection = true
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.project_name}-aurora-final-snapshot"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name = "${var.project_name}-aurora"
  }
}

resource "aws_rds_cluster_instance" "aurora_writer" {
  identifier         = "${var.project_name}-aurora-writer"
  cluster_identifier = aws_rds_cluster.aurora.id

  engine         = aws_rds_cluster.aurora.engine
  engine_version = aws_rds_cluster.aurora.engine_version

  instance_class = "db.t3.medium"

  db_subnet_group_name = aws_db_subnet_group.aurora.name

  publicly_accessible = false

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  performance_insights_enabled          = true
  performance_insights_kms_key_id       = aws_kms_key.aurora.arn
  performance_insights_retention_period = 7

  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.project_name}-aurora-writer"
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${var.project_name}-rds-monitoring"

  assume_role_policy = data.aws_iam_policy_document.rds_monitoring_assume.json

  tags = {
    Name = "${var.project_name}-rds-monitoring"
  }
}

data "aws_iam_policy_document" "rds_monitoring_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
