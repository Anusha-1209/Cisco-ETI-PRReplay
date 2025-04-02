output "role_arn" {
  value = {
    for k, v in local.regions : v => aws_iam_role.role[k].arn
  }
}
