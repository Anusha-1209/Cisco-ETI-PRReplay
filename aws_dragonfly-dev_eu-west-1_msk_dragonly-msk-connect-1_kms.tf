resource "aws_kms_key" "encryption_key" {
  description = "encryption key for msk-kg-connector secrets"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Internal",
        "Effect" : "Allow",
        "Principal" : { "AWS" : data.aws_caller_identity.current.arn },
        "Action" : "kms:*",
        "Resource" : "*"
      },
    ]
  })
}
