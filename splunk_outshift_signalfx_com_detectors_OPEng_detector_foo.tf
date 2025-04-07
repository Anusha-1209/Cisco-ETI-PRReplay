resource "signalfx_detector" "application_delay" {
  count        = length(var.clusters)
  name         = " max average delay - ${var.clusters[count.index]}"
  description  = "your application is slow - ${var.clusters[count.index]}"
  max_delay    = 30
  program_text = <<-EOF
        signal = data('app.delay', filter('cluster','${var.clusters[count.index]}'), extrapolation='last_value', maxExtrapolations=5).max()
        detect(when(signal > 60, '5m')).publish('Processing old messages 5m')
        detect(when(signal > 60, '30m')).publish('Processing old messages 30m')
    EOF
  rule {
    description   = "maximum > 60 for 5m"
    severity      = "Warning"
    detect_label  = "Processing old messages 5m"
    notifications = ["Email,foo-alerts@bar.com"]
  }
  rule {
    description   = "maximum > 60 for 30m"
    severity      = "Critical"
    detect_label  = "Processing old messages 30m"
    notifications = ["Email,foo-alerts@bar.com"]
  }
}
variable "clusters" {
  default = ["clusterA", "clusterB"]
}
