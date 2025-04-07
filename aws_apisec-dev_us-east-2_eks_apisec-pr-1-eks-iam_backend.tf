terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"
    key     = "terraform-state/aws-apisec-dev/iam/apisec-pr-1-eks-access-management.tfstate"
    region  = "us-east-2"
  }
}
