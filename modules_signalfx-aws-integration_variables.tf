variable "splunk_aws_regions" {
  description = "List of AWS regions to enable the Splunk AWS integration in."
  type        = list(string)
  default = [
    "us-east-2",
    "ap-northeast-1",
    "ap-northeast-2",
    "ap-northeast-3",
    "ap-south-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "ca-central-1",
    "eu-central-1",
    "eu-north-1",
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "sa-east-1",
    "us-east-1",
    "us-west-1",
    "us-west-2",
  ]
}

variable "aws_account_name" {
  description = "Name of the AWS account to be used for the Splunk AWS integration."
  type        = string
}
variable "use_metric_streams_sync" {
  description = "Flag to enable the use of metric streams for the Splunk AWS integration."
  type        = bool
  default     = false
}

variable "poll_rate" {
  description = "Polling interval for the Splunk AWS integration."
  type        = number
  default     = 200
}