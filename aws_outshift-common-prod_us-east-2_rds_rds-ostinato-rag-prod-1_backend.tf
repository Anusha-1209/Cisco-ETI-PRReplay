terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aurora-postgres/us-east-2/ostinato-rag-dev-1.tfstate"
    region = "us-east-2"
  }
}
