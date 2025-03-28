# required for the thumbprint list of each EKS cluster

data "tls_certificate" "eks_tls_certificate" {
  for_each = local.cnapp_clusters
  url = "https://${each.value.eks_oidc}"
}

resource "aws_iam_openid_connect_provider" "eks_cluster" {
  for_each = local.cnapp_clusters
  url      = "https://${each.value.eks_oidc}"
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [
    data.tls_certificate.eks_tls_certificate.certificates[0].sha1_fingerprint,
  ]
}
