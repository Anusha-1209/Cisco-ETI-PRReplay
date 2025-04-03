terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key = "terraform-state/vowel-dev-genai/us-east-2/eks/motf-dev-use2-1.tfstate"
    region = "us-east-2"
  }
}
