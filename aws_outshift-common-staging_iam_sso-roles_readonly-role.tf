resource "aws_iam_role" "readonly" {
  name               = "readonly"
  assume_role_policy = file("policies/sso_assume_role_policy.json")
  tags = {
    Name = "readonly"
  }
}

###### SSO Access #######

resource "aws_iam_role_policy_attachment" "readonly-policy-attachment" {
  role       = aws_iam_role.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}