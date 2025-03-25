
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod" 
    key    = "terraform-state/aurora-postgres/eu-central-1/unified-agent-prod-euc1-1.tfstate"
    region = "us-east-2"
  }
}