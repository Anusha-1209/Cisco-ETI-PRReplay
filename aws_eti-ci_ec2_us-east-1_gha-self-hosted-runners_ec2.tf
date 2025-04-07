module "ec2-instance" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  version       = "5.7.1"
  ami           = data.aws_ami.c9-ec2.image_id
  instance_type = "c5.2xlarge"
  name          = var.ec2_name
  vpc_security_group_ids = [data.aws_security_group.default.id,
    data.aws_security_group.cloud_agent_ssh_from_cisco.id,
  data.aws_security_group.cloud_agent_host_monitoring_from_cisco.id]
  subnet_id            = data.aws_subnet.public.id
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name
  key_name             = "eti-jenkins"
  monitoring           = true
  ebs_optimized        = true
  root_block_device = [
    {
      volume_size = 1000
      volume_type = "gp3"
    }
  ]

  cpu_options = {
    core_count       = 4
    threads_per_core = 2
  }

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  private_dns_name_options = {
    enable_resource_name_dns_a_record    = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name = "ec2_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
    }],
  })
}

resource "aws_iam_role_policy" "ec2_ssm_policy" {
  name = "ec2_ssm_policy"
  role = aws_iam_role.ec2_ssm.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["ssm:GetParameter"],
      Resource = "arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:parameter/outshift-platform-gha-token"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "ec2_ssm_instance_profile"
  role = aws_iam_role.ec2_ssm.name
}
