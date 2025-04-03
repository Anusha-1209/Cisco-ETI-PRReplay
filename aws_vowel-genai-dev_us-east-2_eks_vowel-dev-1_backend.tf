terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-prod"
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/vowel-genai-dev/iam/iam-roles.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2"
  }
}
