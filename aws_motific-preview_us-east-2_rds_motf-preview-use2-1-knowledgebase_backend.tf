
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod" 
    key    = "terraform-state/aurora-postgres/us-east-2/motf-preview-use2-1-knowledgebase.tfstate"
    region = "us-east-2"
  }
}