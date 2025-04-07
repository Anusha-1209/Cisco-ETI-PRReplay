resource "aws_iam_policy" "route53-dev-external-DNS" {
  name        = "route53-dev-external-DNS"
  path        = "/"
  description = "Dev route53 policy for external-dns"

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
        "arn:aws:route53:::hostedzone/Z0137785FSHHHEYXY6C5",
        "arn:aws:route53:::hostedzone/Z0137785FSHHHEYXY6C5",
        "arn:aws:route53:::hostedzone/Z0018967101C58GDFOCJV",
        "arn:aws:route53:::hostedzone/Z013754314WJGD2YMIP94",
        "arn:aws:route53:::hostedzone/Z035649519ZKQRXALDKMD",
        "arn:aws:route53:::hostedzone/Z04524991BHRBV1K1S4Q8",
        "arn:aws:route53:::hostedzone/Z10278273JD30E8TPU50R",
        "arn:aws:route53:::hostedzone/Z00421949GD3B8HETDC8",
        "arn:aws:route53:::hostedzone/Z07602441I1PXGXB7BYBF",
        "arn:aws:route53:::hostedzone/Z08763752L9CB6MT5EV9G",
        "arn:aws:route53:::hostedzone/Z048404539K8XI70Q992P",
        "arn:aws:route53:::hostedzone/Z05653962JH35ZUEC9SK",
        "arn:aws:route53:::hostedzone/Z06156631HVMA4ASRUZOI",
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
