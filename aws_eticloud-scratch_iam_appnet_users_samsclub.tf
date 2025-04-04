resource "aws_iam_user" "samsclub" {
  name = "samsclub"
  tags = var.tags
}

data "aws_iam_policy" "banzai_artifacts" {
  name = "appnet-banzai-artifacts"
}

resource "aws_iam_user_policy_attachment" "banzai_artifacts" {
  user       = aws_iam_user.samsclub.name
  policy_arn = data.aws_iam_policy.banzai_artifacts.arn
}
