resource "aws_security_group" "genie-prod-docdb-sg" {
  name        = "genie-prod-docdb-sg"
  description = "Allow inbound traffic from eks-prod-3 to genie prod docdb"
  vpc_id      = "vpc-0b4e6ec021697885d"
  tags        = {
    "Name" = "genie-prod-docdb-sg"
  }
  tags_all    = {
    "Name" = "genie-prod-docdb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "genie-docudb-vpc-sg-ingress-rule" {
  security_group_id = aws_security_group.genie-prod-docdb-sg.id

  cidr_ipv4   = "10.1.0.0/16"
  ip_protocol = "tcp"
  from_port   = 27017
  to_port     = 27017
}