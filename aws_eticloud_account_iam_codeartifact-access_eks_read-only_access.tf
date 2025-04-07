resource "aws_iam_role" "read_only_access" {
  name                  = "codeartifactonly"
  assume_role_policy    = file("./resources/saml_cloudsso-role-policy.json")
  force_detach_policies = true

}


resource "aws_iam_role_policy_attachment" "read_only_access" {
  role       = aws_iam_role.read_only_access.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeArtifactReadOnlyAccess"
}
