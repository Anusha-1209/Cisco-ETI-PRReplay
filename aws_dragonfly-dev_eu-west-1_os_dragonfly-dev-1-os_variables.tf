variable "cisco_cidrs" {
  description = "Cisco network CIDRs"
  default = [
    "52.177.206.0/24",
    "216.151.141.0/24",
    "171.68.0.0/14",
    "66.163.32.0/20",
    "40.79.24.0/24",
    "13.68.72.0/24",
    "40.79.68.0/24",
    "64.103.0.0/16",
    "128.107.0.0/16",
    "20.186.6.0/24",
    "104.208.221.0/24",
    "52.254.19.0/24",
    "13.68.74.0/24",
    "52.254.51.0/24",
    "192.168.24.0/24",
    "171.38.209.0/24",
    "207.182.160.0/19",
    "64.102.0.0/16",
    "66.114.160.0/20",
    "20.186.37.0/24",
    "40.79.62.0/24",
    "52.251.62.0/24",
    "52.232.186.0/24",
    "161.44.0.0/16",
    "52.254.17.0/24",
    "104.209.145.0/24",
    "209.197.192.0/21",
    "40.84.4.0/24",
    "172.27.27.128/26",
    "52.179.217.112/28",
    "40.79.70.0/24",
    "52.254.77.0/24",
    "192.168.5.0/24",
    "3.21.137.64/26",
    "192.168.110.0/23",
    "173.36.0.0/14",
    "72.163.220.0/22",
    "172.18.136.0/21"
  ]
}

variable "domain_name" {
  description = "Domain name for the Amazon OpenSearch Service domain"
  default     = "os-dragonfly-dev-1"
}

variable "engine_version" {
  description = "Engine version for the Amazon OpenSearch Service domain"
  default     = "OpenSearch_2.11"
}

variable "instance_type" {
  description = "Instance type to use for the Amazon OpenSearch Service domain"
  default     = "r6g.large.search"
}

variable "warm_instance_type" {
  description = "Warm instance type to use for the Amazon OpenSearch Service domain"
  default     = "ultrawarm1.medium.search"
}