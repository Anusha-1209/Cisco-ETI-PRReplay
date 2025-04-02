data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/eticcprod/infra/eticloud-scratch-c/aws"
}


resource "aws_iam_policy" "s3-meissa-rw" {
  name        = "s3-meissa-rw"
  path        = "/"
  description = "s3 rw access for meissa"

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
          "arn:aws:s3:::eti-meissa-training-data",
          "arn:aws:s3:::eti-meissa-training-data/*",
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
    Name = "s3-meissa-rw"
  }
}
