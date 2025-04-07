resource "aws_iam_policy" "route53-prod-external-DNS" {
  name        = "route53-prod-external-DNS"
  path        = "/"
  description = "Prod route53 policy for external-dns"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/Z09984062UH4ME1C1V3GD",
        "arn:aws:route53:::hostedzone/Z0137785FSHHHEYXY6C5",
        "arn:aws:route53:::hostedzone/Z048404539K8XI70Q992P",
        "arn:aws:route53:::hostedzone/Z013754314WJGD2YMIP94",
        "arn:aws:route53:::hostedzone/Z0156493114LT3O1X0DQO",
        "arn:aws:route53:::hostedzone/Z08644123N979EDOMIOA3",
        "arn:aws:route53:::hostedzone/Z0967663ETCB929TPGU3",
        "arn:aws:route53:::hostedzone/Z02009793NQUAM5QP94WB",
        "arn:aws:route53:::hostedzone/Z02421812XZYD01417K0B",
        "arn:aws:route53:::hostedzone/Z00421949GD3B8HETDC8",
        "arn:aws:route53:::hostedzone/Z0224987SUCWIS7TRNTE",
        "arn:aws:route53:::hostedzone/Z06863847F5D3O3SJFAU",
        "arn:aws:route53:::hostedzone/Z00470292828I7BCERYH8",
        "arn:aws:route53:::hostedzone/Z034982022T1DOPUHJR2W",
        "arn:aws:route53:::hostedzone/Z03321343THIXFX3HPIKY"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

  tags = var.tags
}
