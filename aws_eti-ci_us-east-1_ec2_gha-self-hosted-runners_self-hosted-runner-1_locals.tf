locals {
  gha_self_hosted_runners = {
    "gha-self-cloud-agent-1" = {
      name = "gha-self-cloud-agent-1"
      instance_type = "c5.xlarge"
    }
    "gha-self-cloud-agent-2" = {
      name = "gha-self-cloud-agent-2"
      instance_type = "c5.xlarge"
    }
  }
}
