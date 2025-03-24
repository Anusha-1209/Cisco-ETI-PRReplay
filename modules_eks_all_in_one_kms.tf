locals {
  kms_description                   = "Customer managed key to encrypt ${local.name} EKS secrets or managed node group volumes"
  partition                         = data.aws_partition.current.partition
  kms_dns_suffix                    = data.aws_partition.current.dns_suffix

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    aws_iam_role.eks_aws_iam_role[0].arn
  ]

  aliases = {
    # Computed since users can pass in computed values for cluster name such as random provider resources
    cluster = { name = "eks/${local.name}" }
  }
}

################################################################################
# Key
################################################################################

resource "aws_kms_key" "this" {
  count                              = var.create_kms ? 1 : 0
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  customer_master_key_spec           = var.customer_master_key_spec
  custom_key_store_id                = var.custom_key_store_id
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = local.kms_description
  enable_key_rotation                = var.enable_key_rotation
  is_enabled                         = var.is_enabled
  key_usage                          = var.key_usage
  multi_region                       = var.multi_region
  policy                             = coalesce(var.policy, data.aws_iam_policy_document.kms_aws_iam_policy_document[0].json)

  tags = var.tags
}


################################################################################
# Policy
################################################################################

data "aws_iam_policy_document" "kms_aws_iam_policy_document" {
  count = var.create_kms ? 1 : 0

  source_policy_documents   = var.source_policy_documents
  override_policy_documents = var.override_policy_documents

  # Default policy - account wide access to all key operations
  dynamic "statement" {
    for_each = var.enable_default_policy ? [1] : []

    content {
      sid       = "Default"
      actions   = ["kms:*"]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
      }
    }
  }

  # Key owner - all key operations
  dynamic "statement" {
    for_each = length(var.key_owners) > 0 ? [1] : []

    content {
      sid       = "KeyOwner"
      actions   = ["kms:*"]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_owners
      }
    }
  }

  # Key administrators - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators
  dynamic "statement" {
    for_each = length(local.key_administrators) > 0 ? [1] : []

    content {
      sid = "KeyAdministration"
      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
        "kms:ReplicateKey",
        "kms:ImportKeyMaterial"
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = local.key_administrators
      }
    }
  }

  # Key users - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users
  dynamic "statement" {
    for_each = length(var.key_users) > 0 ? [1] : []

    content {
      sid = "KeyUsage"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_users
      }
    }
  }

  # Key service users - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration
  dynamic "statement" {
    for_each = length(var.key_service_users) > 0 ? [1] : []

    content {
      sid = "KeyServiceUsage"
      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_service_users
      }

      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = [true]
      }
    }
  }

  # Key service roles for autoscaling - https://docs.aws.amazon.com/autoscaling/ec2/userguide/key-policy-requirements-EBS-encryption.html#policy-example-cmk-access
  dynamic "statement" {
    for_each = length(local.key_service_roles_for_autoscaling) > 0 ? [1] : []

    content {
      sid = "KeyServiceRolesASG"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = local.key_service_roles_for_autoscaling
      }
    }
  }

  dynamic "statement" {
    for_each = length(local.key_service_roles_for_autoscaling) > 0 ? [1] : []

    content {
      sid = "KeyServiceRolesASGPersistentVol"
      actions = [
        "kms:CreateGrant"
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = local.key_service_roles_for_autoscaling
      }

      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = [true]
      }
    }
  }

  # Key cryptographic operations - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-users-crypto
  dynamic "statement" {
    for_each = length(var.key_symmetric_encryption_users) > 0 ? [1] : []

    content {
      sid = "KeySymmetricEncryption"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:ReEncrypt*",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_symmetric_encryption_users
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.key_hmac_users) > 0 ? [1] : []

    content {
      sid = "KeyHMAC"
      actions = [
        "kms:DescribeKey",
        "kms:GenerateMac",
        "kms:VerifyMac",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_hmac_users
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.key_asymmetric_public_encryption_users) > 0 ? [1] : []

    content {
      sid = "KeyAsymmetricPublicEncryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:DescribeKey",
        "kms:GetPublicKey",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_asymmetric_public_encryption_users
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.key_asymmetric_sign_verify_users) > 0 ? [1] : []

    content {
      sid = "KeyAsymmetricSignVerify"
      actions = [
        "kms:DescribeKey",
        "kms:GetPublicKey",
        "kms:Sign",
        "kms:Verify",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_asymmetric_sign_verify_users
      }
    }
  }

  # https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/access-control-managing-permissions.html#KMS-key-policy-for-DNSSEC
  dynamic "statement" {
    for_each = var.enable_route53_dnssec ? [1] : []

    content {
      sid = "Route53DnssecService"
      actions = [
        "kms:DescribeKey",
        "kms:GetPublicKey",
        "kms:Sign",
      ]
      resources = ["*"]

      principals {
        type        = "Service"
        identifiers = ["dnssec-route53.${local.kms_dns_suffix}"]
      }
    }
  }

  # https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/access-control-managing-permissions.html#KMS-key-policy-for-DNSSEC
  dynamic "statement" {
    for_each = var.enable_route53_dnssec ? [1] : []

    content {
      sid       = "Route53DnssecGrant"
      actions   = ["kms:CreateGrant"]
      resources = ["*"]

      principals {
        type        = "Service"
        identifiers = ["dnssec-route53.${local.kms_dns_suffix}"]
      }

      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = ["true"]
      }

      dynamic "condition" {
        for_each = var.route53_dnssec_sources

        content {
          test     = "StringEquals"
          variable = "aws:SourceAccount"
          values   = try(condition.value.account_ids, [local.account_id])
        }
      }

      dynamic "condition" {
        for_each = var.route53_dnssec_sources

        content {
          test     = "ArnLike"
          variable = "aws:SourceArn"
          values   = [try(condition.value.hosted_zone_arn, "arn:${local.partition}:route53:::hostedzone/*")]
        }
      }
    }
  }

  dynamic "statement" {
    for_each = var.key_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_kms_alias" "this" {
  for_each = { for k, v in local.aliases : k => v if var.create_kms }

  name          = var.aliases_use_name_prefix ? null : "alias/${each.value.name}"
  name_prefix   = var.aliases_use_name_prefix ? "alias/${each.value.name}-" : null
  target_key_id = aws_kms_key.this[0].key_id
}

################################################################################
# Grant
################################################################################

resource "aws_kms_grant" "this" {
  for_each = { for k, v in var.grants : k => v if var.create_kms }

  name              = try(each.value.name, each.key)
  key_id            = aws_kms_key.this[0].key_id
  grantee_principal = each.value.grantee_principal
  operations        = each.value.operations

  dynamic "constraints" {
    for_each = length(lookup(each.value, "constraints", {})) == 0 ? [] : [each.value.constraints]

    content {
      encryption_context_equals = try(constraints.value.encryption_context_equals, null)
      encryption_context_subset = try(constraints.value.encryption_context_subset, null)
    }
  }

  retiring_principal    = try(each.value.retiring_principal, null)
  grant_creation_tokens = try(each.value.grant_creation_tokens, null)
  retire_on_delete      = try(each.value.retire_on_delete, null)
}
