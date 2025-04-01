terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vowel-genai-dev/us-east-2/documentdb/pi-dev-use2-documentdb-1.tfstate"
    region = "us-east-2"
  }
}

module "ppu_dev_documentdb_cluster" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-documentdb?ref=develop"
  account_name      = "vowel-genai-dev" # id 961088030672
  application_name  = "pi-dev-use2-documentdb-1"
  environment       = "dev"
  engine_version    = "5.0.0"
  master_username   = "pi"
  instances         = 3
  instance_class    = "db.r6g.xlarge"
  vpc_data_name     = "motf-e2e-use2-data"
  vpc_eks_name      = "pi-dev-use2-1"
  venture_namespace = "ppu"
  secret_path       = "secret/dev/ppu-backend-perf"
}
