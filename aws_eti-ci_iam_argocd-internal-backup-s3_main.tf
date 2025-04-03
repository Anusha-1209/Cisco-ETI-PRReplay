variable "tags" {
  type = map(any)
  default = {
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    ApplicationName    = "IAM"
    Environment        = "Prod"
    ResourceOwner      = "ETI SRE"
  }
}

resource "aws_iam_policy" "argocd-internal-backup-s3" {
  name        = "argocd-internal-backup-s3"
  path        = "/"
  description = "S3 Read Write Policy for argocd-internal-backup S3 bucket"

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
                "s3:CreateJob",
                "s3:PutObject"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::argocd-internal-backup/*",
                "arn:aws:s3:::argocd-internal-backup"
            ]
        }
    ]
}
EOF

  tags = var.tags
}

resource "aws_iam_user" "argocd-internal-backup-user" {
  name          = "argocd-internal-backup-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags
  depends_on = [
    aws_iam_policy.argocd-internal-backup-s3
  ]
}

resource "aws_iam_access_key" "argocd-internal-backup-user-access-key" {
  user    = aws_iam_user.argocd-internal-backup-user.name
  status  = "Active"
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "argocd-internal-backup-s3-attachment" {
  user       = aws_iam_user.argocd-internal-backup-user.name
  policy_arn = aws_iam_policy.argocd-internal-backup-s3.arn
  depends_on = [
    aws_iam_user.argocd-internal-backup-user,
    aws_iam_policy.argocd-internal-backup-s3
  ]
}

locals {
  argocd-internal-backup-user = {
    "aws.access.key.id" = element(
      concat(
        aws_iam_access_key.argocd-internal-backup-user-access-key.*.id,
        [""],
      ),
      0
    )
    "aws.secret.access.key" = element(concat(aws_iam_access_key.argocd-internal-backup-user-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "argocd-internal-backup-user-vault-secret" {
  path      = "secret/prod/argocd/argocd-internal/s3-backup"
  data_json = jsonencode(local.argocd-internal-backup-user)
}


resource "aws_iam_policy" "argocd-internal-backup-s3-rw" {
  name        = "argocd-internal-backup-s3-rw"
  path        = "/"
  description = "S3 Read Write Policy for argocd-internal-backup-s3-rw"

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
        "arn:aws:s3:::cisco-eti-argocd-internal-backup",
        "arn:aws:s3:::cisco-eti-argocd-internal-backup/*"
      ]
    }
  ]
}


EOF

  tags = {
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    ApplicationName    = "IAM"
    Environment        = "Prod"
    ResourceOwner      = "ETI SRE"
  }
}
