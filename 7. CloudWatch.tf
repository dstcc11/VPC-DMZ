resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_status_tunnel1" {
  for_each = local.vpn

  alarm_name          = "VPN_Tunnel_Status_${each.key}_Tunnel1"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  threshold           = "1"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Average"
  dimensions = {
    VpnId     = each.key
    VpnTunnel = "Tunnel1"
  }
  alarm_description = "Alarm for VPN tunnel 1 ${each.key} status"
  actions_enabled   = true
  alarm_actions     = [aws_sns_topic.sns.arn]
}

resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_status_tunnel2" {
  for_each = local.vpn

  alarm_name          = "VPN_Tunnel_Status_${each.key}_Tunnel2"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  threshold           = "1"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Average"
  dimensions = {
    VpnId     = each.key
    VpnTunnel = "Tunnel2"
  }
  alarm_description = "Alarm for VPN tunnel 2 ${each.key} status"
  actions_enabled   = true
  alarm_actions     = [aws_sns_topic.sns.arn]
}

resource "aws_sns_topic" "sns" {
  name = "vpn-alarm-topic"
}

resource "aws_sns_topic_subscription" "sns" {
  topic_arn = aws_sns_topic.sns.arn
  protocol  = "email"
  endpoint  = "dstcc11@gmail.com"
}