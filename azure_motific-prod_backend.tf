terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/azure/motific-prod/eastus/content-safety.tfstate"
    region = "us-east-2"
 }
}