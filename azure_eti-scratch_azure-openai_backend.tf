terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/azure/eti-scratch/azure-openai.tfstate"
    region = "us-east-2"
  }
}