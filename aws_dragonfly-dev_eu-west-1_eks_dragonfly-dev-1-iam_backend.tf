terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-dev/eu-west-1/eks/dragonfly-dev-2-eks-iam.tfstate"
    region = "us-east-2"
  }
}
