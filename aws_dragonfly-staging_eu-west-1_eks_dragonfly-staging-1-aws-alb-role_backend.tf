terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-dragonfly-staging-1/eks/eu-west-1/eks-df-staging-1-aws-alb-role.tfstate"
    region = "us-east-2"
  }
}
