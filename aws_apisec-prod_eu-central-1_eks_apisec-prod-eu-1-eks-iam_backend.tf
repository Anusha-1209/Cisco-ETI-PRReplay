terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-prod"
    key     = "terraform-state/aws-apisec-prod/iam/apisec-prod-eu-1-eks-access-management.tfstate"
    region  = "us-east-2"
  }
}
