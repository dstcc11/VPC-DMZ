######## Locals | Routes #########
locals {
  CDE-igw-route = {
    "10.112.4.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    "10.112.5.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    "10.112.8.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    "10.112.9.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)

  }
  CDE-routes = {
    CDE-tgweni1 = {
      "10.112.6.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.7.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    CDE-tgweni2 = {
      "10.112.6.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.7.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    CDE-fwep1 = {
      "0.0.0.0/0"  = aws_internet_gateway.IGW["CDE"].id
      "10.0.0.0/8" = aws_ec2_transit_gateway.tgw.id
    }
    CDE-fwep2 = {
      "0.0.0.0/0"  = aws_internet_gateway.IGW["CDE"].id
      "10.0.0.0/8" = aws_ec2_transit_gateway.tgw.id
    }
    CDE-public1 = {
      "0.0.0.0/0" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    CDE-public2 = {
      "0.0.0.0/0" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    CDE-subnet1 = {
      "0.0.0.0/0"     = aws_nat_gateway.NGW["CDE1"].id
      "10.0.0.0/8"    = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.7.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.8.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.9.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    CDE-subnet2 = {
      "0.0.0.0/0"     = aws_nat_gateway.NGW["CDE2"].id
      "10.0.0.0/8"    = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.6.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.8.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.9.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    CDE-dmz1 = {
      "0.0.0.0/0"     = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.6.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.7.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.9.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    CDE-dmz2 = {
      "0.0.0.0/0"     = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.6.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.7.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.112.8.0/24" = element(flatten(aws_networkfirewall_firewall.FW["CDE"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
  }
}

###################################################################################################################
resource "aws_route_table" "CDE-igw-route" {
  vpc_id = aws_vpc.VPC["CDE"].id
  dynamic "route" {
    for_each = local.CDE-igw-route
    content {
      cidr_block           = route.key
      gateway_id           = can(regex("igw-", route.value) == 0) ? route.value : null
      nat_gateway_id       = can(regex("nat-", route.value) == 0) ? route.value : null
      transit_gateway_id   = can(regex("tgw-", route.value) == 0) ? route.value : null
      vpc_endpoint_id      = can(regex("vpce-", route.value) == 0) ? route.value : null
      network_interface_id = can(regex("eni-", route.value) == 0) ? route.value : null
    }
  }
  tags = {
    "Name" = "CDE-igw-route"
  }
}

resource "aws_route_table_association" "CDE-igw-route_association" {
  gateway_id     = aws_internet_gateway.IGW["CDE"].id
  route_table_id = aws_route_table.CDE-igw-route.id
}

resource "aws_route_table" "CDE-RT" {
  for_each = local.CDE-routes
  vpc_id   = aws_vpc.VPC["CDE"].id
  dynamic "route" {
    for_each = each.value
    content {
      cidr_block           = route.key
      transit_gateway_id   = can(regex("tgw-", route.value)) ? route.value : null
      gateway_id           = can(regex("igw-", route.value)) ? route.value : null
      nat_gateway_id       = can(regex("nat-", route.value)) ? route.value : null
      vpc_endpoint_id      = can(regex("vpce-", route.value)) ? route.value : null
      network_interface_id = can(regex("eni-", route.value)) ? route.value : null
    }
  }
  tags = {
    Name = "${each.key}-rt"
  }
}

resource "aws_route_table_association" "CDE-rta" {
  for_each       = local.CDE-routes
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.CDE-RT[each.key].id
}