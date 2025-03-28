terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws/dragonfly-prod/iam/cloud-formation-execution-role.tfstate"
    region = "us-east-2"
  }
}
