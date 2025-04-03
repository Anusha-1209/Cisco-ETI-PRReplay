terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-staging/iam/kserve-inference-role.tfstate"
    region = "us-east-2"
  }
}
