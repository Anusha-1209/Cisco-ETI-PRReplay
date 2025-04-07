
   

resource "aws_iam_user" "route53-prod-external-DNS" {
  name = "route53-prod-external-DNS"
  path = "/"
  tags = var.tags
}

data "aws_iam_policy" "route53-dev-external-DNS" {
  name = "route53-dev-external-DNS"
} 

resource "aws_iam_user_policy_attachment" "route53-prod-external-DNS-policy-attachment" {
  user       = aws_iam_user.route53-prod-external-DNS.name
  policy_arn = data.aws_iam_policy.route53-prod-external-DNS.arn
}