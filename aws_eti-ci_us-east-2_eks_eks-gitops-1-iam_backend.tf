terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod" # We separate the different environments into different buckets. 
    # The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. 
    # <bucket_name> in eticloud-tf-state-<bucket_name> should match the Environment tag below.
    key     = "terraform-state/aws-eti-ci/iam/eks-gitops-1-eks-iam.tfstate" # The path should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    region  = "us-east-2" # Do not change.
    # profile = "eticloud" # If you are doing developing Terraform, you can specify a local AWS profile to use for accessing the statefile ONLY. 
    # A CLI login to Keeper is also required.
  }
}