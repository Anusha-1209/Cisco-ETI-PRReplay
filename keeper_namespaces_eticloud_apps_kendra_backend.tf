terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/keeper/eticloud/apps/kendra/kendra-namespace.tfstate"
    region = "us-east-2"
  }
}
