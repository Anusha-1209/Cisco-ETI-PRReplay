resource "aws_sqs_queue" "marvin-dev-sys-tests-use2-1-collect-events" {
  name = "marvin-collect-events-test-use2-1"
  fifo_queue = false
  tags = {
    CSBDataClassification = "Cisco Restricted"
    CSBEnvironment        = "NonProd"
    CSBApplicationName    = "Marvin"
    CSBResourceOwner      = "Outshift SRE"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataTaxonomy       = "Cisco Operations Data"
  }
}
