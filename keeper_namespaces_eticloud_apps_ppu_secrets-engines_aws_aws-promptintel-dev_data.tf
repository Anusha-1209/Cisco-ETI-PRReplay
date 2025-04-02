data "aws_caller_identity" "current" {
  provider = aws.vowel-genai-dev
}

data "aws_iam_access_keys" "vault-secret-engine-user-vowel-genai-dev" {
  provider  = aws.vowel-genai-dev
  user      = "vault-secret-engine-user-vowel-genai-dev"
}

data "aws_iam_role" "jenkins" {
  name = "jenkins"
}