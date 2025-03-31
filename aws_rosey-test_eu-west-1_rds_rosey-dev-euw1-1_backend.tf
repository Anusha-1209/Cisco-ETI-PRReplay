
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod" 
    key    = "terraform-state/aurora-postgres/dev/eu-west-1/rosey.tfstate"
    region = "eu-west-1"
  }
}