terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/azure/motific-staging/eastus/content-safety.tfstate"
    region = "us-east-2"
 }
}