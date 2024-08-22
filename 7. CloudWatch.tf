resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_status_tunnel1" {
  for_each = local.vpn

  alarm_name          = "vpn-${var.site}<-->${each.key}_Tunnel1"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  threshold           = "1"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Average"
  dimensions = {
    TunnelIpAddress = aws_vpn_connection.VPN[each.key].tunnel1_address
  }
  alarm_description = "Alarm for VPN tunnel 1 ${each.key} status"
  actions_enabled   = true
  alarm_actions     = [aws_sns_topic.vpn-sns.arn]
  ok_actions        = [aws_sns_topic.vpn-sns.arn]
}

resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_status_tunnel2" {
  for_each = local.vpn

  alarm_name          = "vpn-${var.site}<-->${each.key}_Tunnel2"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  threshold           = "1"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Average"
  dimensions = {
    TunnelIpAddress = aws_vpn_connection.VPN[each.key].tunnel2_address
  }
  alarm_description = "Alarm for VPN tunnel 2 ${each.key} status"
  actions_enabled   = true
  alarm_actions     = [aws_sns_topic.vpn-sns.arn]
  ok_actions        = [aws_sns_topic.vpn-sns.arn]
}

resource "aws_sns_topic" "vpn-sns" {
  name = "vpn-alarm-topic"
}

resource "aws_sns_topic_subscription" "dstcc11" {
  topic_arn = aws_sns_topic.vpn-sns.arn
  protocol  = "email"
  endpoint  = "dstcc11@gmail.com"
}