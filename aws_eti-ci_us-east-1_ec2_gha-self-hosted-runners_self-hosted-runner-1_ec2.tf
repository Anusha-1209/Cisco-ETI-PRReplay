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
