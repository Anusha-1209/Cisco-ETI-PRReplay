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
        "arn:aws:s3:::eti-mimir-dev-blocks-2",
        "arn:aws:s3:::eti-mimir-dev-blocks-2/*",
        "arn:aws:s3:::eti-mimir-dev-alertmanager-2",
        "arn:aws:s3:::eti-mimir-dev-alertmanager-2/*",
        "arn:aws:s3:::eti-mimir-dev-ruler-2",
        "arn:aws:s3:::eti-mimir-dev-ruler-2/*"
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
          "Federated" : "arn:aws:iam::792074902331:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/42652A69FC8B3F9F2160B72BB7D90657"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-2.amazonaws.com/id/42652A69FC8B3F9F2160B72BB7D90657:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/42652A69FC8B3F9F2160B72BB7D90657:sub" : "system:serviceaccount:mimir:mimir-dev-sa"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::792074902331:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/7F4F5CD617D3EC4ABD39C9CE38CE647E"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-2.amazonaws.com/id/7F4F5CD617D3EC4ABD39C9CE38CE647E:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/7F4F5CD617D3EC4ABD39C9CE38CE647E:sub" : "system:serviceaccount:mimir:mimir-dev-sa"
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
