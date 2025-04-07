# migrate to the ec2 module
# data "aws_vpc" "base" {
#     filter {
#         name = "tag:Name"
#         values = ["${local.group_team}-vpc"]
#     }
# }

# data "aws_subnet_ids" "private_ids" {
#     vpc_id = data.aws_vpc.base.id
#     filter {
#         name = "tag:Name"
#         values = ["${local.group_team}-vpc-private*"]
#     }
# }

# data "aws_subnet" "private_subnets" {
#     for_each = data.aws_subnet_ids.private_ids.ids
#     id = each.value
# }

# data "aws_subnet_ids" "public_ids" {
#     vpc_id = data.aws_vpc.base.id
#     filter {
#         name = "tag:Name"
#         values = ["${local.group_team}-vpc-public*"]
#     }
# }

# data "aws_subnet" "public_subnets" {
#     for_each = data.aws_subnet_ids.public_ids.ids
#     id = each.value
# }


#migrate the AMI selection to the ec2 module
data "aws_ami" "al" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-AmazonLinux_*"]
  }
  most_recent = true
}

data "aws_ami" "al2" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-AmazonLinux2_*"]
  }
  most_recent = true
}

data "aws_ami" "centos6" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-CentOS6_*"]
  }
  most_recent = true
}

data "aws_ami" "centos7" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-CentOS7_*"]
  }
  most_recent = true
}

data "aws_ami" "centos8" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-CentOS8_*"]
  }
  most_recent = true
}

data "aws_ami" "debian8" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-Debian8_*"]
  }
  most_recent = true
}

data "aws_ami" "debian9" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-Debian9_*"]
  }
  most_recent = true
}

data "aws_ami" "debian10" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-Debian10_*"]
  }
  most_recent = true
}

data "aws_ami" "ubuntu1604" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-Ubuntu16.04LTS_*"]
  }
  most_recent = true
}

data "aws_ami" "ubuntu1804" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-Ubuntu18.04LTS_*"]
  }
  most_recent = true
}

data "aws_ami" "ubuntu2004" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-Ubuntu20.04LTS_*"]
  }
  most_recent = true
}

data "aws_ami" "bastion_ami" {
  owners = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardenedDuoJumphost-CentOS7_*"]
  }
  most_recent = true
}

# migrate the vpc selection to the ec2 module
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-private*"]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-public*"]
  }
}

# data "template_file" "sre-imagebuilder_ec2_user_data" {
#   template = file("./user_data.sh")
# }

data "aws_region" "current" {}
data "vault_generic_secret" "aws_dns_credential" {
  path=replace("secret/data/eticcprod/infra/route53", "/data/", "/")
}

data "vault_generic_secret" "aws_infra_credential" {
  path=replace("secret/data/eticcprod/infra/scratch/aws", "/data/", "/")
}