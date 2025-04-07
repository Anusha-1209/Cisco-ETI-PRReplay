resource "aws_iam_policy" "s3-mimir-dev-rw" {
  name        = "s3-mimir-dev-rw"
  path        = "/"
  description = "S3 Read Write Policy for s3-mimir-dev-rw"

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
        "arn:aws:s3:::eti-mimir-dev-blocks",
        "arn:aws:s3:::eti-mimir-dev-blocks/*",
        "arn:aws:s3:::eti-mimir-dev-alertmanager",
        "arn:aws:s3:::eti-mimir-dev-alertmanager/*",
        "arn:aws:s3:::eti-mimir-dev-ruler",
        "arn:aws:s3:::eti-mimir-dev-ruler/*"
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

resource "aws_iam_role" "mimir-dev" {
  name = "mimir-dev"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::626007623524:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/258DDB856D194C8D3FA75228DF43D6E2"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-2.amazonaws.com/id/258DDB856D194C8D3FA75228DF43D6E2:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/258DDB856D194C8D3FA75228DF43D6E2:sub" : "system:serviceaccount:mimir:mimir-dev-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name               = "mimir-dev"
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre_at_cisco_dot_com"
    ApplicationName    = "eticloud-sre-iam"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}

resource "aws_iam_role_policy_attachment" "mimir-dev-s3-policy-attachment" {
  role       = aws_iam_role.mimir-dev.name
  policy_arn = aws_iam_policy.s3-mimir-dev-rw.arn
}
