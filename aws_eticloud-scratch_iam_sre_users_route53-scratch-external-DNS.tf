
   

resource "aws_iam_user" "route53-scratch-external-DNS" {
  name = "route53-scratch-external-DNS"
  path = "/"
  tags = var.tags
}

data "aws_iam_policy" "route53-scratch-external-DNS" {
  name = "route53-scratch-external-DNS"
} 

resource "aws_iam_user_policy_attachment" "route53-scratch-external-DNS-policy-attachment" {
  user       = aws_iam_user.route53-scratch-external-DNS.name
  policy_arn = data.aws_iam_policy.route53-scratch-external-DNS.arn
}