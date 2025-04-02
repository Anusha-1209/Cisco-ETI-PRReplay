locals {
  app_name         = "dragonfly-staging"
  aws_account_name = "dragonfly-staging"
  aws_region       = "eu-west-1"
  account_id       = data.aws_caller_identity.current.account_id

  vpc_id = "dragonfly-compute-staging-1-vpc"

  cluster_name = "eks-df-staging-1"
  oidc_id      = trimprefix(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")

  dragonfly_backend_namespace = "dragonfly-backend"
  dragonfly_msk_cluster_name  = "dragonfly-staging-msk-1"

  arango_connector_plugin_bucket    = "dragonfly-staging-binaries-repository"
  arangodb_connector_logs_bucket    = "dragonfly-staging-kafka-connector-log-files"
  arangodb_connector_execution_role = "kafka-connect-arangodb-role"

  dragonfly_argo_service_account                = "${local.dragonfly_backend_namespace}:dragonfly-thrill-argo"
  dragonfly_streaman_service_account            = "${local.dragonfly_backend_namespace}:dragonfly-streaman-service-account"
  dragonfly_ml_inference_client_service_account = "${local.dragonfly_backend_namespace}:dragonfly-ml-inferenceclient-a-staging-app"
}
