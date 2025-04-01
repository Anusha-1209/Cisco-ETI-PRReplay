resource "aws_iam_policy" "s3-mimir-prod-rw" {
  name        = "s3-mimir-prod-rw"
  path        = "/"
  description = "S3 Read Write Policy for s3-mimir-prod-rw"

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
        "arn:aws:s3:::eti-mimir-prod-blocks",
        "arn:aws:s3:::eti-mimir-prod-blocks/*",
        "arn:aws:s3:::eti-mimir-prod-alertmanager",
        "arn:aws:s3:::eti-mimir-prod-alertmanager/*",
        "arn:aws:s3:::eti-mimir-prod-ruler",
        "arn:aws:s3:::eti-mimir-prod-ruler/*"
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

resource "aws_iam_role" "mimir-prod" {
  name = "mimir-prod"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::626007623524:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/D29D06646B054693B3C7C0B0417E73BF"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-2.amazonaws.com/id/D29D06646B054693B3C7C0B0417E73BF:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/D29D06646B054693B3C7C0B0417E73BF:sub" : "system:serviceaccount:mimir:mimir-prod-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name               = "mimir-prod"
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre_at_cisco_dot_com"
    ApplicationName    = "eticloud-sre-iam"
    Environment        = "Prod"
    ResourceOwner      = "ETI SRE"
  }
}

resource "aws_iam_role_policy_attachment" "mimir-prod-s3-policy-attachment" {
  role       = aws_iam_role.mimir-prod.name
  policy_arn = aws_iam_policy.s3-mimir-prod-rw.arn
}
