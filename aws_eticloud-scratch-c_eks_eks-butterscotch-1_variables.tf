################################################################################
# AWS Provider
################################################################################
variable "aws_account_name" {
  type        = string
  description = "The name of the AWS account where the resources will be created"
}
variable "region" {
  type        = string
  description = "The region where the resources will be created."
}

################################################################################
# Data Sources
################################################################################
variable "vpc_name" {
  type        = string
  description = "The name of the VPC where the EKS cluster will reside."
}

################################################################################
# Tags
################################################################################
variable "application_name" {
  type        = string
  description = "The name of the application."
}
variable "cisco_mail_alias" {
  type        = string
  description = "Who to contact in case of any issues with/queries about a particular resource."
}
variable "data_classification" {
  type        = string
  description = <<EOF
      Data Classification. Options:
      Cisco Restricted
      Cisco Highly Confidential
      Cisco Confidential
      Cisco Public
  EOF
}
variable "data_taxonomy" {
  type        = string
  description = <<EOF
    Data Taxonomy. Options:
      Administrative Data
      Customer Data
      Entrusted Data
      Financing Data
      Support Data
      Telemetry Data
      Cisco Operations Data
      Cisco Strategic Data
      Human Resources Data
    Defaults to Cisco Operations Data.
  EOF
}
variable "environment" {
  type        = string
  description = <<EOF
   Environment. Options:
      Prod
      NonProd
      Sandbox
  EOF
}
variable "resource_owner" {
  type        = string
  description = "Name of the Cisco BU or IT group who is responsible for the particular component."
}

################################################################################
# Cluster
################################################################################
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type        = string
  default     = "1.27"
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

variable "cluster_os" {
  description = "The flavor of Linux the cluster workers should run. The choices are Ubuntu20 and AmazonLinux2."
  type        = string
  default     = "AmazonLinux2"
  validation {
    condition     = contains(["Ubuntu20", "AmazonLinux2"], var.cluster_os)
    error_message = "The Kubernetes OS var: cluster_os can be (Ubuntu20 or AmazonLinux2)."
  }
}

variable "cluster_identity_providers" {
  description = "Map of cluster identity provider configurations to enable for the cluster. Note - this is different/separate from IRSA"
  type        = any
  default     = {}
}
variable "iam_role_arn" {
  description = "Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}
variable "cluster_additional_security_group_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane"
  type        = list(string)
  default     = []
}

################################################################################
# Cluster VPC config
################################################################################
variable "cluster_endpoint_private_access" {
  type        = string
  default     = true
  description = "Whether the Amazon EKS private API server endpoint is enabled. Default is true"
}
variable "cluster_endpoint_public_access" {
  type        = string
  default     = true
  description = "Whether the Amazon EKS public API server endpoint is enabled. Default is true"
}
variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0"
}
variable "control_plane_subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane."
  default     = []
}
variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
  default     = []
}
################################################################################
# Cluster Kubernetes Network Config
################################################################################
variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created"
  type        = string
  default     = "ipv4"
}
variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = "172.20.0.0/16"
}
################################################################################
# Cluster Timeouts
################################################################################
variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default     = {}
}
################################################################################
# Cluster Cloudwatch Log Group
################################################################################
variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 90
}

################################################################################
# KMS Key
################################################################################

variable "bypass_policy_lockout_safety_check" {
  description = "A flag to indicate whether to bypass the key policy lockout safety check. Setting this value to true increases the risk that the KMS key becomes unmanageable"
  type        = bool
  default     = null
}

variable "kms_key_description" {
  description = "The description of the key as viewed in AWS console"
  type        = string
  default     = "The encryption key for the EKS cluster"
}
variable "kms_key_deletion_window_in_days" {
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between `7` and `30`, inclusive. If you do not specify a value, it defaults to `30`"
  type        = number
  default     = 7
}

variable "kms_key_users" {
  description = "A list of IAM ARNs for [key users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users)"
  type        = list(string)
  default     = []
}

variable "kms_key_service_users" {
  description = "A list of IAM ARNs for [key service users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration)"
  type        = list(string)
  default     = []
}


################################################################################
# Private Node Group
################################################################################
variable "private_node_group_instance_types" {
  description = "A list of the instance types to use in the private node group"
  type        = list(string)
}
# variable "private_node_group_ami" {
#   description = "The AMI for the private node group. Defaults to latest."
#   type        = string
#   default     = "value"
# }
variable "private_node_group_desired" {
  description = "The desired number of nodes in the private node group."
  type        = number
}
variable "private_node_group_max" {
  description = "The maximum number of nodes in the private node group."
  type        = number
  default     = 10
}
variable "private_node_group_min" {
  description = "The minimum number of nodes in the private node group."
  type        = number
  default     = 3
}
variable "dataplane_wait_duration" {
  description = "Duration to wait after the EKS cluster has become active before creating the dataplane components (EKS managed nodegroup(s), self-managed nodegroup(s), Fargate profile(s))"
  type        = string
  default     = "30s"
}
