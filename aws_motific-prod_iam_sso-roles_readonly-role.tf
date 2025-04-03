resource "aws_iam_role" "readonly" {
  name               = "readonly"
  assume_role_policy = data.aws_iam_policy_document.assume_role_with_saml.json
  tags = {
    Name = "readonly"
  }
}
resource "aws_iam_policy" "EKSReadOnlyAPIAccess" {
  name        = "EKSReadOnlyAPIAccess"
  path        = "/"
  description = "EKS Read Only API Access"
  policy      = file("policies/EKSReadOnlyAPIAccess.json")
}

###### SSO Access #######

resource "aws_iam_role_policy_attachment" "readonly-policy-attachment" {
  role       = aws_iam_role.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "EKSReadOnlyAPIAccess-policy-attachment" {
  role       = aws_iam_role.readonly.name
  policy_arn = aws_iam_policy.EKSReadOnlyAPIAccess.arn
}