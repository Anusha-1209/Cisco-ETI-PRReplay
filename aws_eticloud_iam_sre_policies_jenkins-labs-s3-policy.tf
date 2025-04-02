resource "aws_iam_policy" "jenkins-labs-s3-policy" {
  name        = "jenkins-labs-s3-policy"
  path        = "/"
  description = "jenkins labs s3 policy"

  policy = <<EOF
{
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::cisco-eti-racktables-backup/*",
                "arn:aws:s3:::cisco-eti-pirl-observium-backup/*",
                "arn:aws:s3:::cisco-eti-sre-backups/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
EOF

  tags = var.tags
}
