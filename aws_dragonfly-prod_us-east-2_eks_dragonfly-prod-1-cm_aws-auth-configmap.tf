locals {
  aws_auth_configmap_b64_decode  = base64decode(data.vault_generic_secret.aws_auth_configmap.data["sre_configmap_json_b64"])
  aws_auth_configmap_json_decode = jsondecode(local.aws_auth_configmap_b64_decode)
  aws_auth_configmap_data = {
    mapRoles = yamlencode(local.aws_auth_configmap_json_decode)
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth_sre_data" {
  provider = kubernetes.eks
  force    = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data
}
