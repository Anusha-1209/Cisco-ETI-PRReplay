resource "aws_iam_user" "crowe" {
  name = "crowe"
  path = "/"
  tags = var.tags
}

data "aws_iam_policy" "external_access_policy" {
  name = "external_access_policy"
}

resource "aws_iam_user_policy_attachment" "external_access_policy" {
  user       = aws_iam_user.crowe.name
  policy_arn = data.aws_iam_policy.external_access_policy.arn
}