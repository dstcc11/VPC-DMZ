######## Locals | Routes #########
locals {
  Prod-igw-route = {
    "10.111.4.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    "10.111.5.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    "10.111.8.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    "10.111.9.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
  }
  Prod-routes = {
    Prod-tgweni1 = {
      "10.111.6.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.7.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    Prod-tgweni2 = {
      "10.111.6.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.7.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    Prod-fwep1 = {
      "0.0.0.0/0"  = aws_internet_gateway.IGW["Prod"].id
      "10.0.0.0/8" = aws_ec2_transit_gateway.tgw.id
    }
    Prod-fwep2 = {
      "0.0.0.0/0"  = aws_internet_gateway.IGW["Prod"].id
      "10.0.0.0/8" = aws_ec2_transit_gateway.tgw.id
    }
    Prod-public1 = {
      "0.0.0.0/0" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    Prod-public2 = {
      "0.0.0.0/0" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    Prod-subnet1 = {
      "0.0.0.0/0"     = aws_nat_gateway.NGW["Prod1"].id
      "10.0.0.0/8"    = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.7.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.8.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.9.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    Prod-subnet2 = {
      "0.0.0.0/0"     = aws_nat_gateway.NGW["Prod2"].id
      "10.0.0.0/8"    = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.6.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.8.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.9.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    Prod-dmz1 = {
      "0.0.0.0/0"     = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.6.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.7.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.9.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
    Prod-dmz2 = {
      "0.0.0.0/0"     = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.6.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.7.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
      "10.111.8.0/24" = element(flatten(aws_networkfirewall_firewall.FW["Prod"].firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
    }
  }
}

###################################################################################################################
resource "aws_route_table" "Prod-igw-route" {
  vpc_id = aws_vpc.VPC["Prod"].id
  dynamic "route" {
    for_each = local.Prod-igw-route
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
    "Name" = "Prod-igw-route"
  }
}

resource "aws_route_table_association" "Prod-igw-route_association" {
  gateway_id     = aws_internet_gateway.IGW["Prod"].id
  route_table_id = aws_route_table.Prod-igw-route.id
}

resource "aws_route_table" "Prod-RT" {
  for_each = local.Prod-routes
  vpc_id   = aws_vpc.VPC["Prod"].id
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

resource "aws_route_table_association" "Prod-rta" {
  for_each       = local.Prod-routes
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.Prod-RT[each.key].id
}