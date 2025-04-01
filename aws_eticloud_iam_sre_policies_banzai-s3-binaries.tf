resource "aws_iam_policy" "banzai-s3-binaries" {
  name        = "banzai-s3-binaries"
  path        = "/"
  description = "Allow fetching binaries from the Banzai S3 bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowListingObjects",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::cisco-eti-banzai-binaries"
            ]
        },
        {
            "Sid": "AllowGettingObjects",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::cisco-eti-banzai-binaries/*"
            ]
        }
    ]
}
EOF

  tags = var.tags
}
