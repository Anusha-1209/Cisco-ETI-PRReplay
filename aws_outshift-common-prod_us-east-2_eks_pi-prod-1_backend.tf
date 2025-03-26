terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-prod"
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/outshift-common-prod/us-east-2/eks/pi-prod-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2"
  }
}
