locals {
  region = "us-east-1"
  vpc = {
    "Prod" = {
      vpc_cidr = "10.111.0.0/16"
      igw      = "true"
      subnets = {
        "Prod-tgweni1" = { cidr = "10.111.0.0/24", az = "a" }
        "Prod-tgweni2" = { cidr = "10.111.1.0/24", az = "b" }
        "Prod-fwep1"   = { cidr = "10.111.2.0/24", az = "a" }
        "Prod-fwep2"   = { cidr = "10.111.3.0/24", az = "b" }
        "Prod-public1" = { cidr = "10.111.4.0/24", az = "a" }
        "Prod-public2" = { cidr = "10.111.5.0/24", az = "b" }
        "Prod-subnet1" = { cidr = "10.111.6.0/24", az = "a" }
        "Prod-subnet2" = { cidr = "10.111.7.0/24", az = "b" }
        "Prod-dmz1"    = { cidr = "10.111.8.0/24", az = "a" }
        "Prod-dmz2"    = { cidr = "10.111.9.0/24", az = "b" }
      }
    }
    "CDE" = {
      vpc_cidr = "10.112.0.0/16"
      igw      = "true"
      subnets = {
        "CDE-tgweni1" = { cidr = "10.112.0.0/24", az = "a" }
        "CDE-tgweni2" = { cidr = "10.112.1.0/24", az = "b" }
        "CDE-fwep1"   = { cidr = "10.112.2.0/24", az = "a" }
        "CDE-fwep2"   = { cidr = "10.112.3.0/24", az = "b" }
        "CDE-public1" = { cidr = "10.112.4.0/24", az = "a" }
        "CDE-public2" = { cidr = "10.112.5.0/24", az = "b" }
        "CDE-subnet1" = { cidr = "10.112.6.0/24", az = "a" }
        "CDE-subnet2" = { cidr = "10.112.7.0/24", az = "b" }
        "CDE-dmz1"    = { cidr = "10.112.8.0/24", az = "a" }
        "CDE-dmz2"    = { cidr = "10.112.9.0/24", az = "b" }
      }
    }
  }
  ngw = {
    "Prod1" = aws_subnet.subnet["Prod-public1"].id
    "Prod2" = aws_subnet.subnet["Prod-public2"].id
    "CDE1"  = aws_subnet.subnet["CDE-public1"].id
    "CDE2"  = aws_subnet.subnet["CDE-public2"].id
  }
  tgw_attach = {
    "Prod" = {
      vpc                  = aws_vpc.VPC["Prod"].id
      subnets              = [aws_subnet.subnet["Prod-tgweni1"].id, aws_subnet.subnet["Prod-tgweni2"].id]
      default_rt_assosiate = "true"
    }
    "CDE" = {
      vpc                  = aws_vpc.VPC["CDE"].id
      subnets              = [aws_subnet.subnet["CDE-tgweni1"].id, aws_subnet.subnet["CDE-tgweni2"].id]
      default_rt_assosiate = "true"
    }
  }
  vpn = {
    "Azure" = {
      peer_ip   = "20.232.25.28"
      remote_nw = ["192.168.3.1/32"]
    }
  }
  sg = {
    "Prod" = aws_vpc.VPC["Prod"].id
    "CDE"  = aws_vpc.VPC["CDE"].id
  }
}

variable "site" {
  default = "Test"
}

######################################################

################ VPC ##################
resource "aws_vpc" "VPC" {
  for_each             = local.vpc
  cidr_block           = each.value.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${each.key}-VPC"
  }
}

################ Subnets ##################
locals {
  subnets_list = flatten([
    for s in keys(local.vpc) : [
      for name, subnet in local.vpc[s].subnets : {
        key  = "${name}"
        vpc  = aws_vpc.VPC[s].id
        name = name
        cidr = subnet.cidr
        az   = "${local.region}${subnet.az}"
      }
    ]
  ])
  sb = { for s in local.subnets_list : s.key => s }
}

resource "aws_subnet" "subnet" {
  for_each          = local.sb
  vpc_id            = each.value.vpc
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

################ NAT Gateway ##################
resource "aws_eip" "nat_eip" {
  for_each = local.ngw
  tags = {
    Name = "NGW-${each.key}"
  }
}

resource "aws_nat_gateway" "NGW" {
  for_each      = local.ngw
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value
  tags = {
    Name = "NGW-${each.key}"
  }
}

################ Internet Gateway ##################
resource "aws_internet_gateway" "IGW" {
  for_each = { for name, config in local.vpc : name => config if config.igw == "true" }
  vpc_id   = aws_vpc.VPC[each.key].id
}

################ Security Group ##################
resource "aws_security_group" "SG" {
  for_each = local.sg
  name     = "SG-${each.key}"
  vpc_id   = each.value
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-${each.key}"
  }
}

################ Key Pair ##################
resource "tls_private_key" "key_pair1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "key_pair1" {
  key_name   = "my-key-pair1"
  public_key = tls_private_key.key_pair1.public_key_openssh
}
# Save file
resource "local_file" "ssh_key1" {
  filename = "${aws_key_pair.key_pair1.key_name}.pem"
  content  = tls_private_key.key_pair1.private_key_pem
}

#output "file_content1" {
#  value     = tls_private_key.key_pair1.private_key_pem
#  sensitive = true
#}

################ Transit Gateway ##################
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = {
    Name = "TGW"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-attach" {
  for_each                                        = local.tgw_attach
  subnet_ids                                      = each.value.subnets
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = each.value.vpc
  appliance_mode_support                          = "enable"
  transit_gateway_default_route_table_association = each.value.default_rt_assosiate
  transit_gateway_default_route_table_propagation = "true"
  tags = {
    "Name" = "${each.key}-tgw-attach"
  }
}

###################### VPN ##################################
resource "aws_customer_gateway" "CG" {
  for_each   = local.vpn
  bgp_asn    = 65002
  ip_address = each.value.peer_ip
  type       = "ipsec.1"
  tags = {
    Name = "CG-${each.key}"
  }
}

resource "aws_vpn_connection" "VPN" {
  for_each            = local.vpn
  transit_gateway_id  = aws_ec2_transit_gateway.tgw.id
  customer_gateway_id = aws_customer_gateway.CG[each.key].id
  type                = "ipsec.1"
  static_routes_only  = true
  tags = {
    Name = "VPN-${each.key}"
  }
}

data "aws_ec2_transit_gateway_vpn_attachment" "vpn-tgw-attachment" {
  for_each           = local.vpn
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpn_connection_id  = aws_vpn_connection.VPN[each.key].id
}

resource "aws_ec2_tag" "vpn-tgw-attachment-tag" {
  for_each    = local.vpn
  resource_id = data.aws_ec2_transit_gateway_vpn_attachment.vpn-tgw-attachment[each.key].id
  key         = "Name"
  value       = "VPN-${each.key}"
}

locals {
  flattened_vpn = flatten([
    for key, value in local.vpn : [
      for cidr in value.remote_nw : {
        key  = key
        cidr = cidr
      }
    ]
  ])
}

resource "aws_ec2_transit_gateway_route" "tgw-vpn-routes" {
  for_each                       = { for i, value in local.flattened_vpn : "${value.key}-${value.cidr}" => value }
  destination_cidr_block         = each.value.cidr
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpn_attachment.vpn-tgw-attachment[each.value.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}
