resource "signalfx_pagerduty_integration" "development-non-urgent" {
  name    = "Development Non-urgent"
  enabled = true
  api_key = "40e4a734f86d400dc0396356ba1c8200"
}

resource "signalfx_pagerduty_integration" "urgent-pagerduty-service" {
  name    = "SRE Urgent PagerDuty Service"
  enabled = true
  api_key = "6f1de70773124204c0fd20931fc1027c"
}