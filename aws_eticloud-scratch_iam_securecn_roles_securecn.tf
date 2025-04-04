resource "aws_iam_policy" "securecn-role-policy" {
  name        = "securecn-role-policy"
  description = "SecureCN Role Policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:*",
                "apigateway:*",
                "lambda:*",
                "ec2:*",
                "ecr:*",
                "sts:*",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:DescribeAddonVersions",
                "eks:CreateCluster"
            ],
            "Resource": "*"
        }
    ]
}
EOF
  tags     = var.tags
  tags_all = {}
}

resource "aws_iam_role" "securecn" {
  name = "securecn"
  description = "SecureCN SAML Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::380642323071:saml-provider/cloudsso.cisco.com"
      },
      "Action": "sts:AssumeRoleWithSAML",
      "Condition": {
        "StringEquals": {
          "SAML:aud": "https://signin.aws.amazon.com/saml"
        }
      }
    },
    {
      "Sid"       : "",
      "Action"    : "sts:AssumeRole",
      "Effect"    : "Allow",
      "Principal" : {
          "AWS" : "arn:aws:iam::380642323071:root"
      }
    }
  ]
}
EOF
  tags     = var.tags
  tags_all = {}
}