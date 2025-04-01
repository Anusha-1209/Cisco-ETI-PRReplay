resource "aws_iam_policy" "eti-identity-policy" {
  name        = "eti-identity-policy"
  path        = "/"
  description = "ETI Identity role policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "IAMListAccounts",
        "Effect" : "Allow",
        "Action" : [
            "iam:ListAccountAliases"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "SESAccess",
        "Effect" : "Allow",
        "Action" : [
            "ses:*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "S3IdentityAssets",
        "Effect" : "Allow",
        "Action" : [
            "s3:*"
        ],
         "Resource": "arn:aws:s3:::cisco-eti-identity-static-assets/*",
      }
    ]
  })

  tags = {
    Name = "eti-identity-ses-rw"
  }
}
