variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "policy_arn" {
  description = "ARN of the PowerUserAccess AWS managed policy to attach to the role"
  type        = string
  default = "arn:aws:iam::aws:policy/PowerUserAccess"
}
variable "tags" {
  description = "Tags to apply to the IAM roles"
  type        = map(string)
}
