variable "tags" {
  type = map(any)
  default = {
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre_at_cisco_dot_com"
    ApplicationName    = "eticloud-sre-iam"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
} 

resource "aws_iam_policy" "cisco-eti-vowel-milvus-dev-s3" {
  name        = "cisco-eti-vowel-milvus-dev-s3"
  path        = "/"
  description = "S3 Read Write Policy for cisco-eti-vowel-milvus-dev S3 bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListStorageLensConfigurations",
                "s3:ListAccessPointsForObjectLambda",
                "s3:GetAccessPoint",
                "s3:PutAccountPublicAccessBlock",
                "s3:GetAccountPublicAccessBlock",
                "s3:ListAllMyBuckets",
                "s3:ListAccessPoints",
                "s3:PutAccessPointPublicAccessBlock",
                "s3:ListJobs",
                "s3:PutStorageLensConfiguration",
                "s3:ListMultiRegionAccessPoints",
                "s3:CreateJob"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::cisco-eti-vowel-milvus-dev/*",
                "arn:aws:s3:::cisco-eti-vowel-milvus-dev"
            ]
        }
    ]
}
EOF

  tags = var.tags
}

resource "aws_iam_user" "cisco-eti-vowel-milvus-dev-user" {
  name          = "cisco-eti-vowel-milvus-dev-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags
  depends_on = [
    aws_iam_policy.cisco-eti-vowel-milvus-dev-s3
  ]
}

resource "aws_iam_access_key" "cisco-eti-vowel-milvus-dev-user-access-key" {
  user    = aws_iam_user.cisco-eti-vowel-milvus-dev-user.name
  status  = "Active"
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "cisco-eti-vowel-milvus-dev-s3-attachment" {
  user       = aws_iam_user.cisco-eti-vowel-milvus-dev-user.name
  policy_arn = aws_iam_policy.cisco-eti-vowel-milvus-dev-s3.arn
  depends_on = [
    aws_iam_user.cisco-eti-vowel-milvus-dev-user,
    aws_iam_policy.cisco-eti-vowel-milvus-dev-s3
  ]
}

locals {
  cisco-eti-vowel-milvus-dev-user = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.cisco-eti-vowel-milvus-dev-user-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.cisco-eti-vowel-milvus-dev-user-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "cisco-eti-vowel-milvus-dev-user-vault-secret" {
   provider = vault.vowel
  path      = "secret/dev/aws/vowel-genai-dev/iam/cisco-eti-vowel-milvus-dev-user"
  data_json = jsonencode(local.cisco-eti-vowel-milvus-dev-user)
}


resource "aws_iam_policy" "cisco-eti-vowel-milvus-dev-s3-rw" {
  name        = "cisco-eti-vowel-milvus-dev-s3-rw"
  path        = "/"
  description = "S3 Read Write Policy for cisco-eti-vowel-milvus-dev-s3-rw"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::cisco-eti-vowel-milvus-dev",
        "arn:aws:s3:::cisco-eti-vowel-milvus-dev/*"
      ]
    }
  ]
}


EOF

  tags = {
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre_at_cisco_dot_com"
    ApplicationName    = "eticloud-sre-iam"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}
