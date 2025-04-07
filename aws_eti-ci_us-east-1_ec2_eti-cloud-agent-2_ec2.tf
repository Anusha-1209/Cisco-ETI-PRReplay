module "ec2-instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "4.3.0"
  ami                         = data.aws_ami.c9-ec2.image_id
  instance_type               = "c5.2xlarge"
  name                        = var.ec2_name
  vpc_security_group_ids      = [data.aws_security_group.default.id,
                                 data.aws_security_group.cloud_agent_ssh_from_cisco.id,
                                 data.aws_security_group.cloud_agent_host_monitoring_from_cisco.id]
  subnet_id                   = tolist(data.aws_subnet_ids.public.ids)[0]
  key_name                    = "eti-jenkins"
  monitoring                  = true
  ebs_optimized               = true
  root_block_device = [
    {
      volume_size = 1000
      volume_type = "gp3"
    }
  ] 
}
  
