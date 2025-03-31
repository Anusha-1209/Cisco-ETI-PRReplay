resource "aws_iam_role" "readonly" {
  name = "readonly"
  assume_role_policy = data.aws_iam_policy_document.assume_role_with_saml.json
  tags = {
    Name = "readonly"
  }
}

###### SSO Access #######

resource "aws_iam_role_policy_attachment" "readonly-policy-attachment" {
  role       = aws_iam_role.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}