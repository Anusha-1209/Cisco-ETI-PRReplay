terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/keeper/eticloud/apps/scs/scs-namespace.tfstate"
    region = "us-east-2"
  }
}
