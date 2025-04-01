resource "aws_iam_policy" "hackathon-role-policy" {
  name = "hackathon-role-policy"
  path = "/"
  description = "Hackathon policy attached to hackathon SAML role"
  policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": [
                    "logs:*",
                    "ec2:*",
                    "iam:*",
                    "s3:*",
                    "ec2-instance-connect:*",
                ],
                "Resource": "*"
            }
        ]
    }
  )
  tags = var.tags
}
