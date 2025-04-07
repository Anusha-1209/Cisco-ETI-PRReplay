# GHA OIDC Provider
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

data "aws_iam_policy_document" "github_assume_role_policy" {
  statement {
    effect     = "Allow"
    principals {
      type        = "Federated"
      identifiers = [ aws_iam_openid_connect_provider.github_actions.arn ]
    }
    actions   = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub" 
      values   = ["repo:cisco-eti/*:*"]
    }
  }
}

# GHA IAM policy
data "aws_iam_policy_document" "gha_s3_bucket_policy" {
  # IAM S3 Bucket read policy
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

# GHA IAM Role
resource "aws_iam_role" "gha_s3_bucket_role" {
  name        = "gh-actions-s3-bucket-role"
  description = "IAM Role for GH Actions workflows"
  tags        = {
    ApplicationName    = "gha-s3-bucket-role"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "Prod"
    ResourceOwner      = "ETI SRE"
  }
  
  assume_role_policy = data.aws_iam_policy_document.github_assume_role_policy.json
  inline_policy {
    name   = "gha-s3-bucket-policy"
    policy = data.aws_iam_policy_document.gha_s3_bucket_policy.json
  }
}

# Add new role ARN to Vault secrets
data "aws_iam_account_alias" "current" {}

resource "vault_kv_secret_v2" "gha_s3_bucket_role-secret" {
  provider  = vault.eticloud_apps_apisec
  mount     = "secret"
  name      = "aws_roles/${data.aws_iam_account_alias.current.account_alias}/gha_s3_bucket_role"
  data_json = jsonencode(
    {
      role_arn = aws_iam_role.gha_s3_bucket_role.arn
    }
  )
}