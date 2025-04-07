resource "aws_iam_policy" "route53-prod-eticloud-io-readwrite" {
  name        = "route53-prod-eticloud-io-readwrite"
  path        = "/"
  description = "Route53 Read Write Policy for prod.eticloud.io Hosted Zone"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "route53:ListTagsForResources",
                "route53:GetChange",
                "route53:GetHostedZone",
                "route53:ChangeResourceRecordSets",
                "route53:ChangeTagsForResource",
                "route53:ListResourceRecordSets",
                "route53:ListTagsForResource"
            ],
            "Resource": [
                "arn:aws:route53:::change/*",
                "arn:aws:route53:::hostedzone/Z048404539K8XI70Q992P",
                "arn:aws:route53:::hostedzone/Z09984062UH4ME1C1V3GD",
                "arn:aws:route53:::hostedzone/Z013754314WJGD2YMIP94",
                "arn:aws:route53:::hostedzone/Z02421812XZYD01417K0B",
                "arn:aws:route53:::hostedzone/Z06863847F5D3O3SJFAU",
                "arn:aws:route53:::hostedzone/Z03446471OFY76TKUO1R9",
                "arn:aws:route53:::hostedzone/Z00421949GD3B8HETDC8",
                "arn:aws:route53:::hostedzone/Z00258893JZT7WDLYD4RC",
                "arn:aws:route53:::hostedzone/Z00470292828I7BCERYH8",
                "arn:aws:route53:::hostedzone/Z0137785FSHHHEYXY6C5",
                "arn:aws:route53:::hostedzone/Z033891316FOYUTCHPB39",
                "arn:aws:route53:::hostedzone/Z0224987SUCWIS7TRNTE",
                "arn:aws:route53:::hostedzone/Z02009793NQUAM5QP94WB",
                "arn:aws:route53:::hostedzone/Z08644123N979EDOMIOA3",
                "arn:aws:route53:::hostedzone/Z0967663ETCB929TPGU3",
                "arn:aws:route53:::hostedzone/Z034982022T1DOPUHJR2W"
            ]
        }
    ]
}
EOF

  tags = var.tags
}

resource "aws_iam_user" "route53-prod-readwrite" {
  name          = "route53-prod-readwrite"
  path          = "/"
  force_destroy = false
  tags          = var.tags
  depends_on = [
    aws_iam_policy.route53-prod-eticloud-io-readwrite
  ]
}

resource "aws_iam_access_key" "route53-prod-readwrite-access-key" {
  user    = aws_iam_user.route53-prod-readwrite.name
  status  = "Inactive"
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "route53-prod-readwrite-attachment" {
  user       = aws_iam_user.route53-prod-readwrite.name
  policy_arn = aws_iam_policy.route53-prod-eticloud-io-readwrite.arn
  depends_on = [
    aws_iam_user.route53-prod-readwrite
  ]
}

locals {
  route53-prod-readwrite = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.route53-prod-readwrite-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.route53-prod-readwrite-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "route53-prod-readwrite-vault-secret" {
  path      = "secret/eticcprod/iam/route53-prod-eticloud"
  data_json = jsonencode(local.route53-prod-readwrite)
}