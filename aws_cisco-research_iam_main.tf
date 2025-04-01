variable "tags" {
  type = map(any)
  default = {
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre_at_cisco_dot_com"
    ApplicationName    = "research-iam"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
} 

resource "aws_iam_policy" "research_rw" {
  name        = "research_rw"
  path        = "/"
  description = "rw access for all buckets that start with cisco-research and with stop/restart EC2 capabilities"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:getBucketVersioning"
        ],
        "Resource": [
          "arn:aws:s3:::cisco-research-*"
        ]
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeTags"
        ],
        "Resource": "*"
      },
      {
        "Sid": "VisualEditor2",
        "Action": [
          "ec2:StartInstances",
          "ec2:StopInstances",	  
          "ec2:RebootInstances"
        ],
        "Resource": [
          "arn:aws:ec2:us-east-2:509581005347:*"
        ],
        "Effect": "Allow"
      }
    ]
  }
  EOF

  tags = var.tags
}
resource "aws_iam_role" "research" {
  name = "research"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = <<-EOF
    {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::509581005347:saml-provider/cloudsso.cisco.com"
        },
        "Action": "sts:AssumeRoleWithSAML",
        "Condition": {
          "StringEquals": {
            "SAML:aud": "https://signin.aws.amazon.com/saml"
          }
        }
      }
    ]
  }
  EOF

tags = var.tags
}

###### SSO Access #######

resource "aws_iam_role_policy_attachment" "research_rw-policy-attachment" {
  role       = aws_iam_role.research.name
  policy_arn = aws_iam_policy.research_rw.arn
}
