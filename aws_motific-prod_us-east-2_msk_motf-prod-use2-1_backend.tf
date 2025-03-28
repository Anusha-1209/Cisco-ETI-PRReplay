terraform {
  backend "s3" {
     # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/msk/us-east-2/motf-prod-use2-1-msk.tfstate" # note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                     # do not change
  }
}