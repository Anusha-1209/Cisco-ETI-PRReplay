
resource "aws_iam_user" "eti-flame-mlflow-s3-dev-user" {
  name          = "eti-flame-mlflow-s3-dev-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags
 
}

resource "aws_iam_access_key" "eti-flame-mlflow-s3-dev-user-key" {
  user    = aws_iam_user.eti-flame-mlflow-s3-dev-user.name
  pgp_key = ""
}
data "aws_iam_policy" "eti-flame-mlflow-s3-readonly" {
  name = "eti-flame-mlflow-s3-readonly"
}

data "aws_iam_policy" "eti-flame-mlflow-s3-readwrite" {
  name = "eti-flame-mlflow-s3-readwrite"
}

resource "aws_iam_user_policy_attachment" "eti-flame-mlflow-s3-dev-user-attachment-1" {
  user       = aws_iam_user.eti-flame-mlflow-s3-dev-user.name
  policy_arn = data.aws_iam_policy.eti-flame-mlflow-s3-readwrite.arn

}

data "null_data_source" "eti-flame-dev-s3-user-access-key-secret" {
  inputs = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.eti-flame-mlflow-s3-dev-user-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.eti-flame-mlflow-s3-dev-user-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "eti-flame-s3-dev-use-vault-secret" {
  path      = "secret/eticcprod/iam/eti-flame-s3-dev-user"
  data_json = jsonencode(data.null_data_source.eti-flame-dev-s3-user-access-key-secret.outputs)
}