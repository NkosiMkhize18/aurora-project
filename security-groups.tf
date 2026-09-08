# Aurora database security group
# Ingress only from known client security groups — no open internet access
resource "aws_security_group" "aurora" {
  name        = "${var.project_name}-aurora-sg"
  description = "Aurora PostgreSQL - ingress from EKS and human access only"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-aurora-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "aurora_from_eks" {
  security_group_id            = aws_security_group.aurora.id
  referenced_security_group_id = aws_security_group.eks_db_client.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "PostgreSQL from EKS microservices"
}

resource "aws_vpc_security_group_ingress_rule" "aurora_from_human" {
  security_group_id            = aws_security_group.aurora.id
  referenced_security_group_id = aws_security_group.human_db_client.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "PostgreSQL from human access via SSM"
}

resource "aws_vpc_security_group_egress_rule" "aurora_deny_all" {
  security_group_id = aws_security_group.aurora.id
  ip_protocol       = "-1"
  cidr_ipv4         = "127.0.0.1/32"
  description       = "Deny all outbound — Aurora does not initiate connections"
}

# -------------------------
# EKS microservices client SG
# Attach this SG to EKS worker nodes / pods to allow Aurora access
# -------------------------
resource "aws_security_group" "eks_db_client" {
  name        = "${var.project_name}-eks-db-client-sg"
  description = "Attach to EKS nodes/pods to allow Aurora PostgreSQL access"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-eks-db-client-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "eks_client_to_aurora" {
  security_group_id            = aws_security_group.eks_db_client.id
  referenced_security_group_id = aws_security_group.aurora.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow outbound to Aurora PostgreSQL"
}

# -------------------------
# Human access client SG
# Attach to the SSM-managed bastion instance used for port forwarding
# -------------------------
resource "aws_security_group" "human_db_client" {
  name        = "${var.project_name}-human-db-client-sg"
  description = "Attach to SSM bastion for human Aurora access via port forwarding"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-human-db-client-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "human_client_to_aurora" {
  security_group_id            = aws_security_group.human_db_client.id
  referenced_security_group_id = aws_security_group.aurora.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow outbound to Aurora PostgreSQL"
}

resource "aws_vpc_security_group_egress_rule" "human_client_to_ssm" {
  security_group_id = aws_security_group.human_db_client.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow HTTPS outbound for SSM agent communication"
}
