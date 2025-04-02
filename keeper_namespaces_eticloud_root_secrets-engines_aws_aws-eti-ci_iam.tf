resource "aws_iam_user" "vault-secret-engine-user-ci" {
  provider = aws.eti-ci
  name     = "vault-secret-engine-user-ci"
}

resource "aws_iam_access_key" "vault-secret-engine-user-ci" {
  provider = aws.eti-ci
  user     = aws_iam_user.vault-secret-engine-user-ci.name
}

resource "aws_iam_user_policy" "vault-secret-engine-user-ci" {
  provider = aws.eti-ci
  name     = "vault-secret-engine-user-ci"
  user     = aws_iam_user.vault-secret-engine-user-ci.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::009736724745:role/jenkins-ec2-readonly"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:GetFederationToken"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

