resource "aws_iam_policy" "sre-s3-elastic-logging-prod-ro" {
  name        = "sre-s3-elastic-logging-prod-ro"
  path        = "/"
  description = "S3 Read Write Policy for sre-s3-elastic-logging-prod-ro"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::logging-elastic-prod",
        "arn:aws:s3:::logging-elastic-prod/*"
      ]
    }
  ]
}


EOF

  tags = var.tags
}
