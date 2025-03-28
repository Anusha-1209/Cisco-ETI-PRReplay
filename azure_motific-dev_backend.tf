terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/azure/motific-dev/content-safety.tfstate"
    region = "us-east-2"
 }
}