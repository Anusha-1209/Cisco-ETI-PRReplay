
resource "aws_iam_user" "eks-gbear-1-certmanager" {
  name = "eks-gbear-1-certmanager"
  path = "/"
  tags = var.tags
}

data "aws_iam_policy" "eti-gbear-1-route53-policy" {
  name = "eti-gbear-1-route53-policy"
}
resource "aws_iam_user_policy_attachment" "eks-gbear-1-certmanager-policy-attachment" {
  user       = aws_iam_user.eks-gbear-1-certmanager.name
  policy_arn = data.aws_iam_policy.eti-gbear-1-route53-policy.arn
}