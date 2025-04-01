resource "aws_iam_user" "grafana-cloudwatch-datasource-user" {
  name          = "grafana-cloudwatch-datasource-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags
}

resource "aws_iam_access_key" "grafana-cloudwatch-datasource-user" {
  user    = aws_iam_user.grafana-cloudwatch-datasource-user.name
  status  = "Inactive"
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "grafana-cloudwatch-datasource-user-policy-attachment" {
  user       = aws_iam_user.grafana-cloudwatch-datasource-user.name
  policy_arn = "arn:aws:iam::626007623524:policy/grafana-cloudwatch-datasource"
}

locals {
  grafana-cloudwatch-datasource-user = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.grafana-cloudwatch-datasource-user.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.grafana-cloudwatch-datasource-user.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "grafana-cloudwatch-datasource-user-vault-secret" {
  path      = "secret/eticcprod/iam/grafana-cloudwatch-datasource-user"
  data_json = jsonencode(local.grafana-cloudwatch-datasource-user)
}