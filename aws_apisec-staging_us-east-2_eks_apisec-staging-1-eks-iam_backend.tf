terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"
    key     = "terraform-state/aws-apisec-staging/iam/apisec-staging-1-eks-access-management.tfstate"
    region  = "us-east-2"
  }
}
