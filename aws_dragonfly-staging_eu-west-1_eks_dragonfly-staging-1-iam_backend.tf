terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-staging/eu-west-1/eks/eks-df-staging-1-iam.tfstate"
    region = "us-east-2"
  }
}
