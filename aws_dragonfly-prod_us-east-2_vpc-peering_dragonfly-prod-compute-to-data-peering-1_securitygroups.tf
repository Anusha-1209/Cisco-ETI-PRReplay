# Security groups
resource "aws_security_group" "compute_to_data" {
  name        = "compute-vpc-1-to-data-vpc-1"
  description = "Allows all communication into data-pvc from the compute-pvc"
  vpc_id      = data.aws_vpc.acceptor_vpc.id
}

resource "aws_security_group" "data_to_compute" {
  name        = "data-vpc-1-to-compute-vpc-1"
  description = "Allows all communication into compute-pvc from the data-pvc"
  vpc_id      = data.aws_vpc.requestor_vpc.id
}

# security group rules because the rules are going to reference the groups
resource "aws_security_group_rule" "compute_to_data" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.compute_to_data.id
  source_security_group_id = aws_security_group.data_to_compute.id
}

resource "aws_security_group_rule" "data_to_compute" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.data_to_compute.id
  source_security_group_id = aws_security_group.compute_to_data.id
}
