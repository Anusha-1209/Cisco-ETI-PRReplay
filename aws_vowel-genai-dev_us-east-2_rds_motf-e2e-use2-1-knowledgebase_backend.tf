
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod" 
    key    = "terraform-state/aurora-postgres/us-east-2/motf-e2e-use2-1-knowledgebas.tfstate"
    region = "us-east-2"
  }
}