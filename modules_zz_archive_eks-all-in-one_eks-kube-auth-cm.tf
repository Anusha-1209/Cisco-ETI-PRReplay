################################################################################
# aws-auth configmap
################################################################################

locals {
  aws_auth_roles = (concat([
    {
      "rolearn"  = "${aws_iam_role.eks_nodegroup.arn}"
      "username" = "system:node:{{EC2PrivateDNSName}}"
      "groups" = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
    {
      "rolearn"  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/admin"
      "username" = "admin"
      "groups" = [
        "system:masters"
      ]
    },
    {
      "rolearn"  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/devops"
      "username" = "devops"
      "groups" = [
        "system:masters"
      ]
    },
    {
      "rolearn"  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/read-only-access"
      "username" = "read-only-access"
      "groups" = [
        "view"
      ]
    }],
    var.aws_auth_roles)
  )
  aws_auth_configmap_data = {
    mapRoles = yamlencode(concat(
      local.aws_auth_roles
    ))
    mapUsers    = yamlencode(var.aws_auth_users)
    mapAccounts = yamlencode(var.aws_auth_accounts)
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  lifecycle {
    # We are ignoring the data here since we will manage it with the resource below
    # This is only intended to be used in scenarios where the configmap does not exist
    ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  count = var.create && var.manage_aws_auth_configmap ? 1 : 0

  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  depends_on = [
    # Required for instances where the configmap does not exist yet to avoid race condition
    kubernetes_config_map.aws_auth,
  ]
}