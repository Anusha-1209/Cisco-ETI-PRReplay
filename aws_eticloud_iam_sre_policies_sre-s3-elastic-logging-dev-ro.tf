resource "aws_iam_policy" "sre-s3-elastic-logging-dev-ro" {
  name        = "sre-s3-elastic-logging-dev-ro"
  path        = "/"
  description = "S3 Read Write Policy for sre-s3-elastic-logging-dev-ro"

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
        "arn:aws:s3:::logging-elastic-dev",
        "arn:aws:s3:::logging-elastic-dev/*"
      ]
    }
  ]
}


EOF

  tags = var.tags
}
