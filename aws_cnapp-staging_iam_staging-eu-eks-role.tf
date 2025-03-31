resource "aws_iam_role" "staging_eu_eks_role" {
  name = "staging-eu-eks-role"
  assume_role_policy = file("policies/sso_assume_role_policy.json")
  tags = {
    Name = "eks-developer-access"
  }
}


resource "aws_iam_policy" "staging_euc_eks_developer_access" {
  name        = "staging-euc-eks-developer-access-policy"
  path        = "/"
  description = "Read-Only SSO IAM role access"
  policy = file("policies/staging_euc_eks_developer_access_policy.json")
}



###### SSO Access #######

resource "aws_iam_role_policy_attachment" "staging_euc_eks-policy-attachment" {
  role       = aws_iam_role.staging_eu_eks_role.name
  policy_arn = aws_iam_policy.staging_euc_eks_developer_access.arn
}