locals {
  vpn = {
    "Azure_CorpX" = {
      peer_ip   = "13.82.24.207"
      remote_nw = ["10.124.96.0/26", "10.124.96.64/26", "10.124.96.128/26", "10.124.97.64/26", "10.124.97.128/25", ]
    }
    "Miss_Rogers" = {
      peer_ip   = "72.14.161.210"
      remote_nw = ["10.230.96.0/24"]
    }
    "Dallas_L3" = {
      peer_ip   = "4.34.179.18"
      remote_nw = ["10.230.64.0/24"]
    }
    "US1_L3" = {
      peer_ip   = "209.66.117.5"
      remote_nw = ["172.17.190.223/32"]
    }
    "CAN1_PGW" = {
      peer_ip   = "209.112.4.5"
      remote_nw = ["172.16.0.0/16"]
    }
  }
}

#############################################################################################################

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
  transit_gateway_id  = aws_ec2_transit_gateway.ca-ce1-tgw.id
  customer_gateway_id = aws_customer_gateway.CG[each.key].id
  type                = "ipsec.1"
  static_routes_only  = true
  tags = {
    Name = "VPN-${each.key}"
  }
}

data "aws_ec2_transit_gateway_vpn_attachment" "vpn-tgw-attachment" {
  for_each           = local.vpn
  transit_gateway_id = aws_ec2_transit_gateway.ca-ce1-tgw.id
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
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ca-ce1-transitgw-firewall-RT.id
}
