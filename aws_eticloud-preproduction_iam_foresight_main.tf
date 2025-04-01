
# IAM Policies
data "aws_iam_policy_document" "assume_role_with_saml" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::792074902331:saml-provider/cloudsso.cisco.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"

      identifiers = ["arn:aws:iam::792074902331:root"]
    }
  }
}

resource "aws_iam_policy" "s3-eti-foresight-app-rw" {
  name        = "s3-eti-foresight-app-rw"
  path        = "/"
  description = "s3 rw access for foresight"

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
          "arn:aws:s3:::eti-foresight-app-dev",
          "arn:aws:s3:::eti-foresight-app-dev/*",
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
    Name = "s3-eti-foresight-app-rw"
  }
}

resource "aws_iam_policy" "kafka-connect-foresight" {
  name        = "kafka-connect-foresight"
  path        = "/"
  description = "kafka-connect access for foresight"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kafkaconnect:*",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "ec2:DescribeSecurityGroups",
                "logs:CreateLogDelivery",
                "logs:GetLogDelivery",
                "logs:DeleteLogDelivery",
                "logs:ListLogDeliveries",
                "logs:PutResourcePolicy",
                "logs:DescribeResourcePolicies",
                "logs:DescribeLogGroups"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/kafkaconnect.amazonaws.com/AWSServiceRoleForKafkaConnect*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "kafkaconnect.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy"
            ],
            "Resource": "arn:aws:iam::*:role/aws-service-role/kafkaconnect.amazonaws.com/AWSServiceRoleForKafkaConnect*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/delivery.logs.amazonaws.com/AWSServiceRoleForLogDelivery*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "delivery.logs.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutBucketPolicy",
                "s3:GetBucketPolicy"
            ],
            "Resource": "arn:aws:s3:::s3-foresight-kafka-connect-logs"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::792074902331:role/msk-apps-1-kafka-connect"
        }
      ]
  })
}

resource "aws_iam_policy" "msk-apps-1-fullaccess" {
  name        = "msk-apps-1-fullaccess"
  path        = "/"
  description = "full access to msk-apps-1"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version":"2012-10-17",
    "Statement":[
        {
          "Sid":"UpdateCluster",
          "Effect":"Allow",
          "Action":[
              "kafka:Describe*",
              "kafka:Get*",
              "kafka:List*",
              "kafka:Update*"
          ],
          "Resource":"arn:aws:kafka:us-east-2:792074902331:cluster/msk-apps-1/b90de523-574c-40e2-8bc5-a7033558e5a1-4"
        }
    ]
  })

  tags = {
    Name = "s3-eti-foresight-app-rw"
  }
}

# IAM Roles
resource "aws_iam_role" "foresight" {
  name                 = "foresight"
  description          = "Foresight SSO IAM role access"
  path                 = "/"
  max_session_duration = "3600"

  force_detach_policies = false
  permissions_boundary  = ""

  assume_role_policy = data.aws_iam_policy_document.assume_role_with_saml.json

}

resource "aws_iam_role_policy_attachment" "foresight-s3-rw-access" {
  role       = aws_iam_role.foresight.name
  policy_arn = aws_iam_policy.s3-eti-foresight-app-rw.arn
}

resource "aws_iam_role_policy_attachment" "foresight-kafka-connect-access" {
  role       = aws_iam_role.foresight.name
  policy_arn = aws_iam_policy.kafka-connect-foresight.arn
}

resource "aws_iam_role_policy_attachment" "foresight-msk-apps-1-fullaccess" {
  role       = aws_iam_role.foresight.name
  policy_arn = aws_iam_policy.msk-apps-1-fullaccess.arn
}

