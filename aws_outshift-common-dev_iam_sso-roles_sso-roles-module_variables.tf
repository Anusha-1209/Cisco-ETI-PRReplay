variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the IAM roles"
  type        = map(string)
}
