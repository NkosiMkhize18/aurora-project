resource "aws_security_group" "aurora" {
  name        = "${var.project_name}-aurora-sg"
  description = "Security group for Aurora database"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-aurora-sg"
  }
}
