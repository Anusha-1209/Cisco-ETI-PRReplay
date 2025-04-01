data aws_caller_identity current {}
data aws_region current {}

data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_msk_cluster" "dragonfly_msk_1" {
  cluster_name = local.dragonfly_msk_cluster_name
}
data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_s3_bucket" "mskconnect_custom_plugin_bucket" {
  bucket = local.arango_connector_plugin_bucket
}

data "aws_s3_bucket" "mskconnect_logs_bucket" {
  bucket = local.arangodb_connector_logs_bucket
}

data "aws_iam_role" "mskconnect_arangodb_execution_role" {
  name = local.arangodb_connector_execution_role
}