terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-dragonfly-production/iam/eks-dragonfly-prod-1-alb-iam.tfstate"
    region = "us-east-2"
  }
}
