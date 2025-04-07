resource "aws_iam_policy" "eti-flame-mlflow-s3-readonly" {
  name        = "eti-flame-mlflow-s3-readonly"
  path        = "/"
  description = "ETI Flame readonly"

  policy = <<EOF
{
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::eti-flame-mlflow-s3",
                "arn:aws:s3:::eti-flame-mlflow-s3/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "iam:ListAccountAliases"
            ],
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
EOF

  tags = var.tags
}