resource "aws_iam_policy" "s3-websites-ro-dev" {
  name        = "s3-websites-ro-dev"
  path        = "/"
  description = "s3 read-only access for websites"

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
          "arn:aws:s3:::eti-gated-assets-dev",
          "arn:aws:s3:::eti-gated-assets-dev/*",
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
    Name = "s3-websites-ro-dev"
  }
}

resource "aws_iam_policy" "s3-websites-ro-staging" {
  name        = "s3-websites-ro-staging"
  path        = "/"
  description = "s3 read-only access for websites"

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
          "arn:aws:s3:::eti-gated-assets-staging",
          "arn:aws:s3:::eti-gated-assets-staging/*",
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
    Name = "s3-websites-ro-staging"
  }
}

resource "aws_iam_policy" "s3-websites-ro-prod" {
  name        = "s3-websites-ro-prod"
  path        = "/"
  description = "s3 read-only access for websites"

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
          "arn:aws:s3:::eti-gated-assets-prod",
          "arn:aws:s3:::eti-gated-assets-prod/*",
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
    Name        = "s3-websites-ro-prod"
    Environment = "Prod"
  }
}
