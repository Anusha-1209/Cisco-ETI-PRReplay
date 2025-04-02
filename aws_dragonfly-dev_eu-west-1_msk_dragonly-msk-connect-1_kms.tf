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
      {
        "Sid" : "External",
        "Effect" : "Allow",
        "Principal" : { "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/admin" },
        "Action" : [
          "kms:Decrypt",
          "kms:Describe*",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:GetKeyPolicy*",
        ],
        Resource : "*"
      },
      {
        "Sid" : "External",
        "Effect" : "Allow",
        "Principal" : { "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/dragonfly-kg-connector-role" },
        "Action" : [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource : "*"
      }
    ]
  })
}
