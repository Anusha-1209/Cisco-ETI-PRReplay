resource "aws_iam_policy" "s3-syc-rw" {
  name        = "s3-syc-rw"
  path        = "/"
  description = "s3 rw access for symphony-cerebrum"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:getBucketVersioning"
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
          "s3:ListAllMyBuckets"
        ],
        "Resource" : "*"
      }
    ],
    "Version" : "2012-10-17"
  })

  tags = {
    Name = "s3-syc-rw"
  }
}
