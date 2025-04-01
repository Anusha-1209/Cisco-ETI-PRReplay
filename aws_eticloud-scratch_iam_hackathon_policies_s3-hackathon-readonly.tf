resource "aws_iam_policy" "s3-hackathon-readonly" {
  name        = "s3-hackathon-readonly"
  path        = "/"
  description = "s3 access for hackathon"

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
          "arn:aws:s3:::eti-hackathon-*",
          "arn:aws:s3:::eti-hackathon-*/*"
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
    Name = "s3-hackathon-readonly"
  }
}
