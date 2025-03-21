locals {
  name                      = "eks-butterscotch-1"
  region                    = "us-east-2"

  # VPC values
  vpc_cidr                  = "10.0.0.0/16"

  # EKS Values

  # TBD

  # Vault AWS Credential Path
  aws_infra_credential_path = "secret/eticcprod/infra/eticloud-scratch-c/aws"
}