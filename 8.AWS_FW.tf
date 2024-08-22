# AWS Firewall
resource "aws_networkfirewall_rule_group" "rule-group" {
  for_each = local.vpc
  capacity = 1000
  name     = "${each.key}-rule-group"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 5
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              source {
                address_definition = "0.0.0.0/0"
              }
              source {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "firewall-policy" {
  for_each = local.vpc
  name     = "${each.key}-firewall-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:drop"]
    stateless_fragment_default_actions = ["aws:drop"]
    stateless_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.rule-group["${each.key}"].arn
    }
  }
}

resource "aws_networkfirewall_firewall" "FW" {
  for_each            = local.vpc
  name                = "FW-${each.key}"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.firewall-policy["${each.key}"].arn
  vpc_id              = aws_vpc.VPC["${each.key}"].id
  dynamic "subnet_mapping" {
    for_each = [aws_subnet.subnet["${each.key}-fwep1"].id, aws_subnet.subnet["${each.key}-fwep2"].id]

    content {
      subnet_id = subnet_mapping.value
    }
  }
  tags = {
    Name       = "FW-${each.key}"
    Enviroment = "Testing"
  }
}

resource "aws_cloudwatch_log_group" "Log_group" {
  for_each = local.vpc
  name     = "LG-${each.key}"
}

resource "aws_networkfirewall_logging_configuration" "fw_logs" {
  for_each     = local.vpc
  firewall_arn = aws_networkfirewall_firewall.FW["${each.key}"].arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.Log_group["${each.key}"].name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.Log_group["${each.key}"].name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}