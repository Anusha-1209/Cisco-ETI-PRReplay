resource "aws_sns_topic" "dragonfly-urgent-pagerduty" {
  name = "dragonfly-urgent-pagerduty"
}
resource "aws_sns_topic_subscription" "dragonfly-urgent-pagerduty-email-target" {
  topic_arn              = aws_sns_topic.dragonfly-urgent-pagerduty.arn
  protocol               = "email"
  endpoint               = "panoptica-cndr-urgent@cisco-eti.pagerduty.com"
  endpoint_auto_confirms = true
}
