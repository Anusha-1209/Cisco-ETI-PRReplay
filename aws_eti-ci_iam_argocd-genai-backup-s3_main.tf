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

resource "aws_iam_policy" "argocd-genai-backup-s3" {
  name        = "argocd-genai-backup-s3"
  path        = "/"
  description = "S3 Read Write Policy for argocd-genai-backup S3 bucket"

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
                "arn:aws:s3:::argocd-genai-backup/*",
                "arn:aws:s3:::argocd-genai-backup"
            ]
        }
    ]
}
EOF

  tags = var.tags
}

resource "aws_iam_user" "argocd-genai-backup-user" {
  name          = "argocd-genai-backup-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags
  depends_on = [
    aws_iam_policy.argocd-genai-backup-s3
  ]
}

resource "aws_iam_access_key" "argocd-genai-backup-user-access-key" {
  user    = aws_iam_user.argocd-genai-backup-user.name
  status  = "Active"
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "argocd-genai-backup-s3-attachment" {
  user       = aws_iam_user.argocd-genai-backup-user.name
  policy_arn = "arn:aws:iam::009736724745:policy/argocd-genai-backup-s3"
  depends_on = [
    aws_iam_user.argocd-genai-backup-user,
    aws_iam_policy.argocd-genai-backup-s3
  ]
}

locals {
  argocd-genai-backup-user = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.argocd-genai-backup-user-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.argocd-genai-backup-user-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "argocd-genai-backup-user-vault-secret" {
  path      = "secret/eticcprod/iam/argocd-genai-backup-user"
  data_json = jsonencode(local.argocd-genai-backup-user)
}


resource "aws_iam_policy" "argocd-genai-backup-s3-rw" {
  name        = "argocd-genai-backup-s3-rw"
  path        = "/"
  description = "S3 Read Write Policy for argocd-genai-backup-s3-rw"

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
        "arn:aws:s3:::cisco-eti-argocd-genai-backup",
        "arn:aws:s3:::cisco-eti-argocd-genai-backup/*"
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
    Environment        = "Prod"
    ResourceOwner      = "ETI SRE"
  }
}
