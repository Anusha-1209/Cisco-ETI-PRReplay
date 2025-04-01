terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/keeper/eticloud/root/eticloud.tfstate"
    region = "us-east-2"
  }
}
