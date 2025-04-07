terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-eticloud/iam/ecr-access-management.tfstate"
    region = "us-east-2"
  }
}
