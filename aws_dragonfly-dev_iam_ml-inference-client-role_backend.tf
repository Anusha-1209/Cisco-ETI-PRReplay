terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-dev/iam/ml-inference-client-role.tfstate"
    region = "us-east-2"
  }
}
