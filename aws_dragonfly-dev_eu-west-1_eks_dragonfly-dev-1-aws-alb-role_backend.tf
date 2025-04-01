terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"                                                                          # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/aws-dragonfly-dev-1/eks/eu-west-1/eks-dragonfly-dev-2-eks-eks-aws-alb-role.tfstate" # Note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                                                          # Do not change
  }
}
