terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/keeper/eticloud/apps/a3po/a3po-namespace.tfstate"
    region = "us-east-2"
  }
}