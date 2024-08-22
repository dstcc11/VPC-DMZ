variable "vpn_connections" {
  description = "List of VPN Connection IDs to monitor"
  type        = list(string)
  default     = ["vpn-0c5ce3f6425270b6f", "vpn-0fb9afd22eee6cec8"]
}

resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_status_tunnel1" {
  count               = length(var.vpn_connections)
  alarm_name          = "VPN_Tunnel_Status_Tunnel1_${element(var.vpn_connections, count.index)}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  threshold           = "1"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Minimum"
  dimensions = {
    VpnId     = element(var.vpn_connections, count.index)
    VpnTunnel = "Tunnel1"
  }
  alarm_description = "Alarm for VPN tunnel 1 ${element(var.vpn_connections, count.index)} status"
  actions_enabled   = true
  alarm_actions     = [aws_sns_topic.sns.arn]
}

resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_status_tunnel2" {
  count               = length(var.vpn_connections)
  alarm_name          = "VPN_Tunnel_Status_Tunnel2_${element(var.vpn_connections, count.index)}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  threshold           = "1"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Minimum"
  dimensions = {
    VpnId     = element(var.vpn_connections, count.index)
    VpnTunnel = "Tunnel2"
  }
  alarm_description = "Alarm for VPN tunnel 2 ${element(var.vpn_connections, count.index)} status"
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