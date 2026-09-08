data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# -------------------------
# SSM bastion instance
# No SSH, no public IP — accessed exclusively via SSM Session Manager
# -------------------------
resource "aws_instance" "ssm_bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.human_db_client.id]

  iam_instance_profile = aws_iam_instance_profile.ssm_bastion.name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${var.project_name}-ssm-bastion"
  }
}

resource "aws_iam_role" "ssm_bastion" {
  name = "${var.project_name}-ssm-bastion"

  assume_role_policy = data.aws_iam_policy_document.ssm_bastion_assume.json

  tags = {
    Name = "${var.project_name}-ssm-bastion"
  }
}

data "aws_iam_policy_document" "ssm_bastion_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_bastion" {
  role       = aws_iam_role.ssm_bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_bastion" {
  name = "${var.project_name}-ssm-bastion"
  role = aws_iam_role.ssm_bastion.name
}

# -------------------------
# VPC endpoints for SSM
# Required so the bastion in the private subnet can reach SSM without internet
# -------------------------
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-vpc-endpoints-sg"
  description = "Allow HTTPS from within the VPC to SSM VPC endpoints"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-vpc-endpoints-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_https" {
  security_group_id = aws_security_group.vpc_endpoints.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = aws_vpc.main.cidr_block
  description       = "HTTPS from VPC CIDR"
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-ssmmessages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-ec2messages-endpoint"
  }
}
