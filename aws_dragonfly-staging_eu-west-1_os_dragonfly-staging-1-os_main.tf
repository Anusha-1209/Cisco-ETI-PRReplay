resource "aws_opensearch_domain" "dragonfly_staging_1_os" {
  depends_on = [
    # aws_iam_service_linked_role.dragonfly_linked_role,
    aws_cloudwatch_log_group.dragonfly_staging_1_os_logs,
  ]

  domain_name     = var.domain_name
  engine_version  = var.engine_version
  access_policies = null

  cluster_config {
    dedicated_master_enabled = true
    dedicated_master_count   = 3
    dedicated_master_type    = var.instance_type

    instance_count = 3
    instance_type  = var.instance_type

    warm_enabled = true
    warm_count   = 3
    warm_type    = var.warm_instance_type

    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = 3
    }

    cold_storage_options {
      enabled = true
    }
  }

  vpc_options {
    subnet_ids = data.aws_subnets.db_subnets.ids
    security_group_ids = [
      aws_security_group.dragonfly_staging_1_os.id
    ]
  }

  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = vault_generic_secret.os_auth_credentials.data["username"]
      master_user_password = vault_generic_secret.os_auth_credentials.data["password"]
    }
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"

    custom_endpoint_enabled = false
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = aws_kms_key.encryption_key.arn
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = 1000
    iops        = 3000
    throughput  = 250
  }

  log_publishing_options {
    log_type                 = "AUDIT_LOGS"
    enabled                  = true
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.dragonfly_staging_1_os_logs.arn
  }

  auto_tune_options {
    desired_state       = "ENABLED"
    rollback_on_disable = "NO_ROLLBACK"
  }


  tags = {
    DataClassification = "Cisco Restricted"
    Environment        = "NonProd"
    ApplicationName    = var.domain_name
    ResourceOwner      = "eti sre"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataTaxonomy       = "Cisco Operations Data"
  }
}

resource "aws_opensearch_domain_policy" "this" {
  domain_name     = aws_opensearch_domain.dragonfly_staging_1_os.domain_name
  access_policies = data.aws_iam_policy_document.dragonfly_admin_access_policy.json
}
