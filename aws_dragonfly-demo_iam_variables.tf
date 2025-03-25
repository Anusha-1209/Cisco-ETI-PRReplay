################################################################################
# Provider Configuration
################################################################################
variable "aws_account_name" {
  type        = string
  description = "The AWS account name"
}
variable "aws_account_id" {
  type        = string
  description = "The AWS account id"
}
variable "aws_region" {
  description = "Region where EKS will be created"
  type        = string
}

################################################################################
# EKS IRSA
################################################################################

variable "eks_irsa" {
  type = map(map(object({
    services_accounts = list(string)
    resources_names   = list(string)
  })))
  default     = null
  description = "Configuration of the IAM Roles for k8s service accounts"
}