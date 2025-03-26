terraform {
  backend "s3" {
    bucket = "motifi-staging-iam"                               
    key    = "terraform-state/s3/us-east-2/motifi-staging-iam.tfstate" 
    region = "us-east-2"                                               
 }
}