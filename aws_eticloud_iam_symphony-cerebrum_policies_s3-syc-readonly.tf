resource "aws_iam_policy" "s3-syc-readonly" {
  name        = "s3-syc-readonly"
  path        = "/"
  description = "s3 access for symphony-cerebrum"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::symphony-cerebrum-s3-dev",
          "arn:aws:s3:::symphony-cerebrum-s3-dev/*",
          "arn:aws:s3:::symphony-cerebrum-s3-input-data-dev",
          "arn:aws:s3:::symphony-cerebrum-s3-input-data-dev/*",
          "arn:aws:s3:::symphony-cerebrum-s3-staging",
          "arn:aws:s3:::symphony-cerebrum-s3-staging/*",
          "arn:aws:s3:::symphony-cerebrum-s3-input-data-staging",
          "arn:aws:s3:::symphony-cerebrum-s3-input-data-staging/*"
        ]
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "iam:ListAccountAliases"
        ],
        "Resource" : "*"
      }
    ],
    "Version" : "2012-10-17"
  })

  tags = {
    Name = "s3-syc-readonly"
  }
}
