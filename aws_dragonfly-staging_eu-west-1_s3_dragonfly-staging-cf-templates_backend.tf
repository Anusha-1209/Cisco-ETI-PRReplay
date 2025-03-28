terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-sandbox"
    key    = "terraform-state/aws/dragonfly-staging/s3/dragonfly-staging-cf-templates.tfstate"
    region = "us-east-2"
  }
}
