terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/keeper/eticloud/apps/ospo/ospo-namespace.tfstate"
    region = "us-east-2"
  }
}
