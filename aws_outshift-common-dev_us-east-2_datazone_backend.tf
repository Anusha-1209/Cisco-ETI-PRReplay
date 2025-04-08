terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/dataone/us-east-2/datazone.tfstate"
    region = "us-east-2"
  }
}
