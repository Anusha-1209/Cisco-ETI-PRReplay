
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod" 
    key    = "terraform-state/aurora-postgres/us-east-2/unified-agent-prod-use2-1.tfstate"
    region = "us-east-2"
  }
}