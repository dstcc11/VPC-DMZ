locals {
  ec2_prod = {
    "Test_prod1" = { #1
      ami             = data.aws_ami.latest_amz_linux.id
      instance_type   = "t2.micro"
      vpc             = "Prod"
      subnet          = "subnet1"
      private_ip      = "10.111.6.200"
      public_ip       = false
      inbound_allowed = ["0.0.0.0/0", ]
      protocol        = "-1"
      port            = ["0"]
    }
  }
}

locals {
  ec2_cde = {
    "Test_cde1" = { #1
      ami             = data.aws_ami.latest_amz_linux.id
      instance_type   = "t2.micro"
      vpc             = "CDE"
      subnet          = "subnet1"
      private_ip      = "10.112.6.200"
      public_ip       = false
      inbound_allowed = ["0.0.0.0/0", ]
      protocol        = "-1"
      port            = ["0"]
    }
    "Test_cde2" = { #2
      ami             = data.aws_ami.latest_amz_linux.id
      instance_type   = "t2.micro"
      vpc             = "CDE"
      subnet          = "subnet2"
      private_ip      = ""
      public_ip       = false
      inbound_allowed = ["0.0.0.0/0", ]
      protocol        = "-1"
      port            = ["0"]
    }
    "Test_cde_dmz" = { #3
      ami             = data.aws_ami.latest_amz_linux.id
      instance_type   = "t2.micro"
      vpc             = "CDE"
      subnet          = "dmz1"
      private_ip      = "10.112.8.200"
      public_ip       = true
      inbound_allowed = ["1.1.1.1/32", "2.2.2.2/32"]
      protocol        = "TCP"
      port            = ["22", "80"]
    }
  }
}

locals {
  ec2 = merge(local.ec2_prod, local.ec2_cde)
}

##################################################################################
data "aws_ami" "latest_amz_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-*"]
  }
}

data "aws_ami" "latest_amz_windows2016srv" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }
}
data "aws_ami" "latest_amz_windows2019srv" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

data "aws_ami" "latest_amz_windows2022srv" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}

resource "aws_security_group" "SG-EC2" {
  for_each = local.ec2
  name     = "SG-${each.key}"
  vpc_id   = aws_vpc.VPC["${each.value.vpc}"].id
  dynamic "ingress" {
    for_each = each.value.port
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = each.value.protocol
      cidr_blocks = each.value.inbound_allowed
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "SG-${each.key}"
  }
}

resource "aws_instance" "EC2" {
  for_each                    = local.ec2
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = aws_subnet.subnet["${each.value.vpc}-${each.value.subnet}"].id
  private_ip                  = each.value.private_ip != "" ? each.value.private_ip : null
  associate_public_ip_address = each.value.public_ip
  vpc_security_group_ids      = [aws_security_group.SG-EC2["${each.key}"].id]
  key_name                    = aws_key_pair.key_pair1.key_name
  iam_instance_profile        = aws_iam_instance_profile.ssm-iam-instance-profile.name
  user_data                   = <<EOF
        #!/bin/bash
            yum install -y httpd nano w3m
            chkconfig httpd on
            service httpd start
            echo "Testing EC2 - Test1 - PROD" > /var/www/html/index.html
            yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
        EOF
  tags = {
    Name = each.key
  }
}

