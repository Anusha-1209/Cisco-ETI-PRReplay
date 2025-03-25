data "vault_generic_secret" "aws_infra_credential" {
  path        = "secret/infra/aws/eticloud-scratch-c/terraform_admin"
}

data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = ["eks-sraradhy-1"]
  }
}
