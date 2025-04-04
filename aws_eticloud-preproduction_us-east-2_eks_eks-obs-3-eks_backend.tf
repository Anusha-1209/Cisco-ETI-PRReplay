terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-eticloud-preprod/eks/us-east-2/eks-obs-3-eks.tfstate"
    region = "us-east-2"
  }
}
