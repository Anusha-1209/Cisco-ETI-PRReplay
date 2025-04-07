# Describes the statefile and table in the eticloud aws account. Each Atlantis project should have it's own statefile (key)
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-apisec-prod/iam/apisec-prod-1-eks-karpenter-roles.tfstate"
    region = "us-east-2"
  }
}