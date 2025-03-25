
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod" 
    key    = "terraform-state/aurora-postgres/us-east-2/vowel-dev-1-knowledge-base.tfstate"
    region = "us-east-2"
  }
}