# Describes the statefile and table in the eticloud aws account. Each Atlantis project should have it's own statefile (key)
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-eti-ci/vpc/eu-north-1/eks-gitops-cnapp-1-karpenter-roles.tfstate"
    region = "us-east-2"
  }
}