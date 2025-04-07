
data "aws_ami" "c9-ec2" {
  owners      = ["849570812361"] # <--- The Cloud 9 AWS account
  most_recent = true

  filter {
    name   = "name"
    values = ["CiscoHardened-Ubuntu22*amd64*"]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.ec2_vpc.id
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-public*"]
  }
}

data "aws_vpc" "ec2_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_route53_zone" "this" {
  name = "ci.eticloud.io"
}

# Security Groups
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.ec2_vpc.id
  name   = "default"
}
data "aws_security_group" "cloud_agent_ssh_from_cisco" {
  vpc_id = data.aws_vpc.ec2_vpc.id
  name = "cloud_agent_ssh_from_cisco"
}

data "aws_security_group" "cloud_agent_host_monitoring_from_cisco" {
  vpc_id = data.aws_vpc.ec2_vpc.id
  name = "cloud_agent_host_monitoring_from_cisco"
}
