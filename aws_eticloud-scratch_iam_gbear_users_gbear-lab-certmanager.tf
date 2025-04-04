
resource "aws_iam_user" "gbear-lab-certmanager" {
  name = "gbear-lab-certmanager"
  path = "/"
  tags = var.tags
}
# Inserted to remind us we need this. But it is duplicated in eks-gbear-1-certmanager
# data "aws_iam_policy" "eti-gbear-1-route53-policy" {
#   name = "eti-gbear-1-route53-policy"
# }
resource "aws_iam_user_policy_attachment" "gbear-lab-certmanager-policy-attachment" {
  user       = aws_iam_user.gbear-lab-certmanager.name
  policy_arn = data.aws_iam_policy.eti-gbear-1-route53-policy.arn
}