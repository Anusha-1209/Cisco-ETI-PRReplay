resource "aws_sqs_queue" "github_webhook_queue" {
  name                        = local.sqs_name
  sqs_managed_sse_enabled     = true

  tags = {
    DataClassification = var.DataClassification
    Environment        = var.Environment
    ApplicationName    = var.ApplicationName
    ResourceOwner      = var.ResourceOwner
    CiscoMailAlias     = var.CiscoMailAlias
    DataTaxonomy       = var.DataTaxonomy
  }
}