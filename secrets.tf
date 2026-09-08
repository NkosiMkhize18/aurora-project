resource "aws_secretsmanager_secret" "aurora_master" {
  count = var.enable_aurora ? 1 : 0

  name       = "${var.project_name}/aurora/master"
  kms_key_id = aws_kms_key.aurora[0].arn

  recovery_window_in_days = 7

  tags = {
    Name = "${var.project_name}-aurora-master"
  }
}

resource "aws_secretsmanager_secret_version" "aurora_master" {
  count = var.enable_aurora ? 1 : 0

  secret_id = aws_secretsmanager_secret.aurora_master[0].id

  secret_string = jsonencode({
    username = var.db_master_username
    password = var.db_master_password
    engine   = "aurora-postgresql"
    host     = aws_rds_cluster.aurora[0].endpoint
    port     = aws_rds_cluster.aurora[0].port
    dbname   = var.db_name
  })
}
