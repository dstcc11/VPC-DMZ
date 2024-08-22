locals {
  sg-ep = {
    "prod-ep" = {
      vpc  = aws_vpc.VPC["Prod"].id
      cidr = ["10.111.0.0/16"]
    }
    "cde-ep" = {
      vpc  = aws_vpc.VPC["CDE"].id
      cidr = ["10.112.0.0/16"]
    }
  }
}

resource "aws_security_group" "SG-EP" {
  for_each = local.sg-ep
  vpc_id   = each.value.vpc
  name     = "SG-${each.key}"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = each.value.cidr
  }
  tags = {
    Name = "SG-${each.key}"
  }
}


resource "aws_iam_role" "ssm-role" {
  name        = "ssm-role"
  description = "The role for SSM to manage EC2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
  role       = aws_iam_role.ssm-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm-iam-instance-profile" {
  name = "ssm-iam-instance-profile"
  role = aws_iam_role.ssm-role.name
}

locals {
  endpoints = {
    "endpoint-ssm" = {
      name = "ssm"
    },
    "endpoint-ssmm-essages" = {
      name = "ssmmessages"
    },
    "endpoint-ec2-messages" = {
      name = "ec2messages"
    }
  }
}

resource "aws_vpc_endpoint" "ssm_prod_endpoints" {
  vpc_id              = aws_vpc.VPC["Prod"].id
  subnet_ids          = [aws_subnet.subnet["Prod-fwep1"].id, aws_subnet.subnet["Prod-fwep2"].id]
  for_each            = local.endpoints
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${local.region}.${each.value.name}"
  security_group_ids  = [aws_security_group.SG-EP["prod-ep"].id]
  tags = {
    Name = "ssm_prod_endpoints_${each.value.name}"
  }
}

resource "aws_vpc_endpoint" "ssm_cde_endpoints" {
  vpc_id              = aws_vpc.VPC["CDE"].id
  subnet_ids          = [aws_subnet.subnet["CDE-fwep1"].id, aws_subnet.subnet["CDE-fwep2"].id]
  for_each            = local.endpoints
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${local.region}.${each.value.name}"
  security_group_ids  = [aws_security_group.SG-EP["cde-ep"].id]
  tags = {
    Name = "ssm_cde_endpoints_${each.value.name}"
  }
}