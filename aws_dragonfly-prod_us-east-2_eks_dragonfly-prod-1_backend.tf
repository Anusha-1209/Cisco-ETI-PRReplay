terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-dragonfly-production/eks/us-east-2/eks-dragonfly-prod-1.tfstate"
    region = "us-east-2"
  }
}
