resource "aws_iam_policy" "eti-hackathon-role-policy" {
  name        = "eti-hackathon-role-policy"
  description = "eti-hackathon Role Policy"
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

resource "aws_iam_role" "hackathon" {
  name = "hackathon"
  description = "hackathon SAML Role"
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

### Role policy attachement
data "aws_iam_policy" "s3-hackathon-readonly" {
  name = "s3-hackathon-readonly"
}

data "aws_iam_policy" "s3-hackathon-rw" {
  name = "s3-hackathon-rw"
}


resource "aws_iam_role_policy_attachment" "hackathon-s3-policy-attachment" {
  role       = aws_iam_role.hackathon.name
  policy_arn = data.aws_iam_policy.s3-hackathon-readonly.arn
}
resource "aws_iam_role_policy_attachment" "hackathon-s3-rw-policy-attachment" {
  role       = aws_iam_role.hackathon.name
  policy_arn = data.aws_iam_policy.s3-hackathon-rw.arn
}