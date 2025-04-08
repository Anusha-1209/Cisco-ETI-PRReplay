variable "cisco_cidrs" {
  description = "Cisco network CIDRs"
  default = [
    "216.151.141.0/24",
    "171.68.0.0/14",
    "128.107.0.0/16",
    "171.38.209.0/24",
    "192.168.5.0/24",
    "10.0.0.0/8",
    "172.27.27.128/26",
    "192.168.110.0/23",
    "192.168.24.0/24",
    "161.44.0.0/16",
    "173.36.0.0/14",
    "72.163.0.0/16",
    "64.101.0.0/16",
    "64.103.0.0/17",
    "18.221.201.234/32",
    "192.118.76.0/22",
    "195.27.35.158/32",
    "50.216.158.99/32",
    "64.102.249.0/24",
    "151.186.183.24/32", # Cisco Secure Access IPSEC/TLS VPN US-West
    "151.186.183.87/32", # Cisco Secure Access IPSEC/TLS VPN US-West
    "151.186.182.23/32", # Cisco Secure Access IPSEC/TLS VPN US-East
    "151.186.182.87/32", # Cisco Secure Access IPSEC/TLS VPN US-East
    "151.186.181.22/32", # Cisco Secure Access IPSEC/TLS VPN United Kingdom
    "151.186.181.86/32", # Cisco Secure Access IPSEC/TLS VPN United Kingdom
    "151.186.180.23/32", # Cisco Secure Access IPSEC/TLS VPN Germany
    "151.186.180.87/32", # Cisco Secure Access IPSEC/TLS VPN Germany
    "151.186.177.83/32", # Cisco Secure Access IPSEC/TLS VPN India (West)
    "151.186.177.21/32", # Cisco Secure Access IPSEC/TLS VPN India (West)
  ]
}

variable "vpc_name" {
  description = "Name of the VPC to create these cloud nodes in"
  default     = "etici-vpc-us-east-1"
}
