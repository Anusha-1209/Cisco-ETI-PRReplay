# Role ID
output "dragonfly_streaman_connector_role_id" {
  value = aws_iam_role.dragonfly_streaman.arn
}

output "dragonfly_thrill_msk_role_id" {
  value = aws_iam_role.dragonfly_thrill_msk_writer.arn
}
