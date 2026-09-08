resource "aws_db_subnet_group" "aurora" {
  name = "${var.project_name}-aurora"

  subnet_ids = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id
  ]

  tags = {
    Name = "${var.project_name}-aurora"
  }
}
