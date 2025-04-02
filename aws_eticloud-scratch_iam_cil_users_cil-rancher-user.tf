
resource "aws_iam_user" "cil-rancher-user" {
  name          = "cil-rancher-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags

}

resource "aws_iam_access_key" "cil-rancher-user-access-key" {
  user    = aws_iam_user.cil-rancher-user.name
  pgp_key = ""
}

data "aws_iam_policy" "sts_cil_assumerole" {
  name = "sts_cil_assumerole"
}
resource "aws_iam_user_policy_attachment" "cil-rancher_route53-cil-policy-attachment" {
  user       = aws_iam_user.cil-rancher-user.name
  policy_arn = data.aws_iam_policy.sts_cil_assumerole.arn
}

data "aws_iam_policy" "sts_cilappnet_assumerole" {
  name = "sts_cilappnet_assumerole"
}
resource "aws_iam_user_policy_attachment" "cil-rancher_route53-cilappnet-policy-attachment" {
  user       = aws_iam_user.cil-rancher-user.name
  policy_arn = data.aws_iam_policy.sts_cilappnet_assumerole.arn
}


data "null_data_source" "cil-rancher-user-access-key-secret" {
  inputs = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.cil-rancher-user-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.cil-rancher-user-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "cil-rancher-user-vault-secret" {
  path      = "secret/eticcprod/iam/cil-rancher-scratch-eticloud"
  data_json = jsonencode(data.null_data_source.cil-rancher-user-access-key-secret.outputs)
}