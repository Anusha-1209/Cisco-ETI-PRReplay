
resource "aws_iam_user" "route53-cil-user" {
  name          = "route53-cil-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags

}

resource "aws_iam_access_key" "route53-cil-user-access-key" {
  user    = aws_iam_user.route53-cil-user.name
  pgp_key = ""
}
data "aws_iam_policy" "route53-cil-scratch-eticloud-io-readwrite" {
  name = "route53-cil-scratch-eticloud-io-readwrite"
}

resource "aws_iam_user_policy_attachment" "route53-cil-policy-attachment" {
  user       = aws_iam_user.route53-cil-user.name
  policy_arn = data.aws_iam_policy.route53-cil-scratch-eticloud-io-readwrite.arn

}

data "null_data_source" "route53-cil-user-access-key-secret" {
  inputs = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.route53-cil-user-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.route53-cil-user-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "route53-cil-user-vault-secret" {
  path      = "secret/eticcprod/iam/route53-cil-scratch-eticloud"
  data_json = jsonencode(data.null_data_source.route53-cil-user-access-key-secret.outputs)
}