terraform {
  backend "s3" {
    bucket         = "eti-sre-imagebuilder"
    key            = "imagebuilder-ec2.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}
