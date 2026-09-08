resource "aws_secretsmanager_secret" "aurora_master" {
  name       = "${var.project_name}/aurora/master"
  kms_key_id = aws_kms_key.aurora.arn

  recovery_window_in_days = 7

  tags = {
    Name = "${var.project_name}-aurora-master"
  }
}

resource "aws_secretsmanager_secret_version" "aurora_master" {
  secret_id = aws_secretsmanager_secret.aurora_master.id

  secret_string = jsonencode({
    username = var.db_master_username
    password = var.db_master_password
    engine   = "aurora-postgresql"
    host     = aws_rds_cluster.aurora.endpoint
    port     = aws_rds_cluster.aurora.port
    dbname   = var.db_name
  })
}
