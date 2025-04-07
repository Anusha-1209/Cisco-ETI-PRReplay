variable "aws_account" {
  description = "AWS account ID"
  type        = string
  default     = "626007623524"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "argocd-bootstrap-1"
}

variable "cluster_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}
