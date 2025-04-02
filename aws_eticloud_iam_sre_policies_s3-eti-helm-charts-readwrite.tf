resource "aws_iam_policy" "s3-eti-helm-charts-readwrite" {
  name        = "s3-eti-helm-charts-readwrite"
  path        = "/"
  description = "S3 Read Write Policy for eti-helm-charts"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowListObjects",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::eti-helm-charts"
    },
    {
      "Sid": "AllowObjectsCRUD",
      "Effect": "Allow",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::eti-helm-charts/*"
    }
  ]
}
EOF

  tags = var.tags
}
