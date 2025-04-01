terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-prod/us-east-2/eks/dragonfly-prod-1-iam.tfstate"
    region = "us-east-2"
  }
}
