locals {
  nlb_settings = {
    "nlbtest" = {
      target          = ["Test_cde1", "Test_cde2", "", ]
      port            = "22"
      inbound_allowed = ["0.0.0.0/0", ]
      nlb_vpc         = "CDE"
    }
  }
}

####################################################################################
resource "aws_eip" "EIP" {
  for_each = local.nlb_settings
  tags = {
    Name = "NLB-${each.key}"
  }
}

resource "aws_security_group" "SG_NLB" {
  for_each = local.nlb_settings
  vpc_id   = aws_vpc.VPC[each.value.nlb_vpc].id
  ingress {
    from_port   = each.value.port
    to_port     = each.value.port
    protocol    = "TCP"
    cidr_blocks = each.value.inbound_allowed
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "NLB-${each.key}"
  }
}

resource "aws_lb" "NLB" {
  for_each           = local.nlb_settings
  name               = "NLB-${each.key}"
  internal           = "false"
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id     = aws_subnet.subnet["${each.value.nlb_vpc}-public1"].id
    allocation_id = aws_eip.EIP[each.key].id
  }
  security_groups = [aws_security_group.SG_NLB[each.key].id]
}

resource "aws_lb_listener" "listener-nlb" {
  for_each          = local.nlb_settings
  load_balancer_arn = aws_lb.NLB[each.key].arn
  port              = each.value.port
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.NLB-TG[each.key].arn
  }
}

resource "aws_lb_target_group" "NLB-TG" {
  for_each = local.nlb_settings
  name     = "NLB-${each.key}"
  port     = each.value.port
  protocol = "TCP"
  # target_type = "ip"
  vpc_id = aws_vpc.VPC[each.value.nlb_vpc].id
}

resource "aws_lb_target_group_attachment" "attach-NLBTG-1" {
  for_each         = { for k, v in local.nlb_settings : k => v if v.target[0] != "" }
  target_group_arn = aws_lb_target_group.NLB-TG[each.key].arn
  target_id        = aws_instance.EC2[each.value.target[0]].id
  port             = each.value.port
  #availability_zone = "all"
}

resource "aws_lb_target_group_attachment" "attach-NLBTG-2" {
  for_each         = { for k, v in local.nlb_settings : k => v if v.target[1] != "" }
  target_group_arn = aws_lb_target_group.NLB-TG[each.key].arn
  target_id        = aws_instance.EC2[each.value.target[1]].id
  port             = each.value.port
  #availability_zone = "all"
}

resource "aws_lb_target_group_attachment" "attach-NLBTG-3" {
  for_each         = { for k, v in local.nlb_settings : k => v if v.target[2] != "" }
  target_group_arn = aws_lb_target_group.NLB-TG[each.key].arn
  target_id        = aws_instance.EC2[each.value.target[2]].id
  port             = each.value.port
  #availability_zone = "all"
}

