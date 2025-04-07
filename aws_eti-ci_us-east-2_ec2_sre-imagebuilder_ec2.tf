
# AWS SG for sre-imagebuilder instance
module "sre-imagebuilder-sg00" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"
  name        = "sre-imagebuilder-sg00"
  description = "Security group 00 for imagebuilder"
  vpc_id      = data.aws_vpc.vpc.id
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      cidr_blocks = join(",", var.cisco_cidrs)
      description = "Allow full communication with var.cisco_cidrs. Only applicable to publicly facing instances"
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 1
  ingress_with_self = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      self        = true
      description = "Allows full communication with itself"

    }
  ]
  computed_egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  number_of_computed_egress_with_cidr_blocks = 1
}

module "sre-imagebuilder-sg01" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"
  name        = "sre-imagebuilder-sg01"
  description = "Security group 01 for imagebuilder"
  vpc_id      = data.aws_vpc.vpc.id
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = join(",", var.cisco_cidrs)
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 1
}

module "ec2-imagebuilder" {
  source = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-ec2.git?ref=master"
  ec2_ami                         = "ami-009ed61c52936baf6"
  ec2_associate_public_ip_address = true
  ec2_instance_type               = "m5.metal"
  ec2_instance_count              = 1
  ec2_name                        = "sre-imagebuilder"
  ec2_user_data                   = templatefile("user_data.tftpl", {aws_region = data.aws_region.current.name})
  ec2_vpc_security_group_ids = [
    module.sre-imagebuilder-sg00.this_security_group_id,
    module.sre-imagebuilder-sg01.this_security_group_id
  ]

  ec2_subnet_ids          = data.aws_subnet_ids.public.ids
  ec2_key_name            = "sre-imagebuilder"
  ec2_volume_size         = 600
  ec2_bucket_name         = "eti-sre-imagebuilder"
  ec2_host_record_name    = "imagebuilder"
  hosted_zone_id          = "Z01509942J6PWHDXM6B0U"
  tag_application_name    = "sre-imagebuilder"
  tag_data_classification = "Cisco Confidential"
  tag_environment         = "Sandbox"
  tag_cisco_mail_alias    = "eti-sre@cisco.com"
  tag_data_taxonomy       = "Cisco Operations Data"
  tag_resource_owner      = "ETI SRE"
}
