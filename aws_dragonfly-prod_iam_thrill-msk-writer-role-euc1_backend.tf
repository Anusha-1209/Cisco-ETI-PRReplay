terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws/dragonfly-prod/iam/thrill-msk-writer-role-euc1.tfstate"
    region = "us-east-2"
  }
}
