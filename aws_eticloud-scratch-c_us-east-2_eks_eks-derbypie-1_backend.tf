################################################################################
# Provider
################################################################################

terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"
    key     = "terraform-state/aws/eticloud-scratch-c/us-east-2/eks/eks-derbypie-1.tfstate"
    region  = "us-east-2"
  }
}