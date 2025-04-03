terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-nonprod"                                                      # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/eticloud-preproduction/us-east-2/eks/eks-dev-3-new-1.tfstate" # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2"                                                                         # DO NOT CHANGE.

  }
}

resource "aws_eks_cluster" "eks-dev-3-13e" {
  enabled_cluster_log_types = ["api", "audit", "authenticator"]
  encryption_config {
    provider {
      key_arn = "arn:aws:kms:us-east-2:792074902331:key/9b86e16b-c4f4-403b-9119-81b0cd91df9e"
    }
    resources = ["secrets"]
  }
  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
  }
  name     = "eks-dev-3"
  role_arn = "${aws_iam_role.eks-dev-3-cluster-20230120212040751300000001-312.arn}"
  tags = {
    ApplicationName    = "us-east-2-eks-dev-3"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
  version = "1.27"
  vpc_config {
    endpoint_private_access = true
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = ["${aws_security_group.eks-dev-3-cluster-2023012021204265150000000a-33c.id}"]
    subnet_ids              = ["subnet-07e74a82fc47fe239",
                               "subnet-08d24e2a62e3af41b",
                               "subnet-09f09a87b4cd0a6fb",
                               "subnet-0a4591d22994e7637",
                               "subnet-0a814ee7896ea1251",
                               "subnet-0aef567d7e1145676",
                               "subnet-0afc07ba1444e1aa9",
                               "subnet-0c5c0392589c629d2",
                               "subnet-0c710596cb8a6e8a4",
                               "subnet-0d8365a1c6ae0bbb7",
                               "subnet-0ef5dfd1b42066e0a",
                               "subnet-06e2d8a5af8017ab0"]
  }
}

resource "aws_vpc" "eks-dev-3-vpc-984" {
  cidr_block                     = "10.16.0.0/16"
  # enable_classiclink_dns_support = false
  enable_dns_hostnames           = true
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc"
    ResourceOwner                     = "ETI SRE"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
  }
}

resource "aws_subnet" "eks-dev-3-vpc-private-us-east-2b-05c" {
  cidr_block                          = "10.16.2.0/24"
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc-private-us-east-2b"
    ResourceOwner                     = "ETI SRE"
    Tier                                 = "Private"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
  vpc_id = "vpc-0805a6b333887a75e"
}

resource "aws_subnet" "eks-dev-3-vpc-ec-us-east-2b-8d9" {
  cidr_block                          = "10.16.32.0/24"
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc-ec-us-east-2b"
    ResourceOwner                     = "ETI SRE"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
  }
  vpc_id = "vpc-0805a6b333887a75e"
}

resource "aws_subnet" "eks-dev-3-vpc-public-us-east-2c-7f0" {
  cidr_block                          = "10.16.13.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc-public-us-east-2c"
    ResourceOwner                     = "ETI SRE"
    Tier                                 = "Public"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
  vpc_id = "vpc-0805a6b333887a75e"
}

resource "aws_subnet" "eks-dev-3-vpc-db-us-east-2c-59a" {
  cidr_block                          = "10.16.23.0/24"
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc-db-us-east-2c"
    ResourceOwner                     = "ETI SRE"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
  }
  vpc_id = "vpc-0805a6b333887a75e"
}


resource "aws_subnet" "eks-dev-3-vpc-public-us-east-2b-4be" {
  cidr_block                          = "10.16.12.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc-public-us-east-2b"
    ResourceOwner                     = "ETI SRE"
    Tier                                 = "Public"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
  vpc_id = "vpc-0805a6b333887a75e"
}

resource "aws_security_group" "eks-cluster-sg-eks-dev-3-333627-a31" {
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  ingress {
    from_port = 0
    protocol  = "-1"
    self      = true
    to_port   = 0
  }
  name = "eks-cluster-sg-eks-dev-3-333627"
  tags = {
    Name                                 = "eks-cluster-sg-eks-dev-3-333627"
    "kubernetes.io/cluster/eks-dev-3" = "owned"
  }
  vpc_id = "vpc-0805a6b333887a75e"
  # The following attributes have default values introduced when importing the resource into terraform: [revoke_rules_on_delete timeouts]
  lifecycle {
    ignore_changes = [revoke_rules_on_delete, timeouts]
  }
}

resource "aws_security_group" "eks-dev-3-cluster-2023012021204265150000000a-33c" {
  description = "EKS cluster security group"
  egress {
    description     = "To node 1025-65535"
    from_port       = 1025
    protocol        = "tcp"
    security_groups = ["sg-057ce692597d8d313"]
    to_port         = 65535
  }
  ingress {
    description     = "Node groups to cluster API"
    from_port       = 443
    protocol        = "tcp"
    security_groups = ["sg-057ce692597d8d313"]
    to_port         = 443
  }
  tags = {
    ApplicationName    = "us-east-2-eks-dev-3"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    Name               = "eks-dev-3-cluster"
    ResourceOwner      = "ETI SRE"
  }
  vpc_id = "vpc-0805a6b333887a75e"
  # The following attributes have default values introduced when importing the resource into terraform: [revoke_rules_on_delete timeouts]
  lifecycle {
    ignore_changes = [revoke_rules_on_delete, timeouts]
  }
}

resource "aws_subnet" "eks-dev-3-vpc-public-us-east-2a-cc4" {
  cidr_block                          = "10.16.11.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc-public-us-east-2a"
    ResourceOwner                     = "ETI SRE"
    Tier                                 = "Public"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
  vpc_id = "vpc-0805a6b333887a75e"
}

resource "aws_subnet" "eks-dev-3-vpc-ec-us-east-2c-e39" {
  cidr_block                          = "10.16.33.0/24"
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc-ec-us-east-2c"
    ResourceOwner                     = "ETI SRE"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
  }
  vpc_id = "vpc-0805a6b333887a75e"
}

resource "aws_subnet" "eks-dev-3-vpc-private-us-east-2c-adf" {
  cidr_block                          = "10.16.3.0/24"
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc-private-us-east-2c"
    ResourceOwner                     = "ETI SRE"
    Tier                                 = "Private"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
  vpc_id = "vpc-0805a6b333887a75e"
}

resource "aws_subnet" "eks-dev-3-vpc-private-us-east-2a-4e0" {
  cidr_block                          = "10.16.1.0/24"
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc-private-us-east-2a"
    ResourceOwner                     = "ETI SRE"
    Tier                                 = "Private"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
  vpc_id = "vpc-0805a6b333887a75e"
}

resource "aws_subnet" "eks-dev-3-vpc-db-us-east-2b-2a1" {
  cidr_block                          = "10.16.22.0/24"
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc-db-us-east-2b"
    ResourceOwner                     = "ETI SRE"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
  }
  vpc_id = "vpc-0805a6b333887a75e"
}

resource "aws_subnet" "eks-dev-3-vpc-ec-us-east-2a-822" {
  cidr_block                          = "10.16.31.0/24"
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                                 = "eks-dev-3-vpc-ec-us-east-2a"
    ResourceOwner                     = "ETI SRE"
    "kubernetes.io/cluster/eks-dev-3" = "shared"
  }
  vpc_id = "vpc-0805a6b333887a75e"
}

resource "aws_iam_role" "eks-dev-3-cluster-20230120212040751300000001-312" {
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EKSClusterAssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
})
  inline_policy {
    name   = "eks-dev-3-cluster"
    policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Effect": "Deny",
      "Resource": "*"
    }
  ]
})
  }
  managed_policy_arns = ["${aws_iam_policy.eks-dev-3-cluster-ClusterEncryption2023012021210166530000000e-9a7.arn}", "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]
  tags = {
    ApplicationName    = "us-east-2-eks-dev-3"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}

resource "aws_iam_policy" "eks-dev-3-cluster-ClusterEncryption2023012021210166530000000e-9a7" {
  description = "Cluster encryption policy to allow cluster role to utilize CMK provided"
  name        = "eks-dev-3-cluster-ClusterEncryption2023012021210166530000000e"
  policy      = jsonencode({
  "Statement": [
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ListGrants",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:kms:us-east-2:792074902331:key/9b86e16b-c4f4-403b-9119-81b0cd91df9e"
    }
  ],
  "Version": "2012-10-17"
})
  tags = {
    ApplicationName    = "us-east-2-eks-dev-3"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}

resource "aws_eks_node_group" "eks-dev-3-public-nodegroup-87f" {
  ami_type       = "CUSTOM"
  capacity_type  = "ON_DEMAND"
  cluster_name   = "${aws_eks_cluster.eks-dev-3-13e.id}"
  disk_size      = 0
  instance_types = ["m5a.2xlarge"]
  launch_template {
    version = "1"
  }
  node_role_arn   = "${aws_iam_role.eks-dev-3-public-ng-role-20230120213215278600000015-c5a.arn}"
  release_version = "ami-0a4aa32529d82497d"
  scaling_config {
    min_size = 0
    max_size = 1
    desired_size = 0
  }
  subnet_ids = ["${aws_subnet.eks-dev-3-vpc-private-us-east-2c-adf.id}", "${aws_subnet.eks-dev-3-vpc-private-us-east-2b-05c.id}", "${aws_subnet.eks-dev-3-vpc-private-us-east-2a-4e0.id}"]
  tags = {
    ApplicationName    = "us-east-2-eks-dev-3"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    Name               = "eks-dev-3-public-nodegroup"
    ResourceOwner      = "ETI SRE"
  }
  taint {
    effect = "PREFER_NO_SCHEDULE"
    key    = "node-type"
    value  = "public"
  }
  update_config {
    max_unavailable_percentage = 33
  }
  version = "1.27"
}

resource "aws_launch_template" "eks-dev-3-127-public-20231011104642636500000001-762" {
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = "true"
      encrypted             = "true"
      volume_size           = 100
      volume_type           = "gp3"
    }
  }
  default_version         = 1
  description             = "eks-dev-3 Public Launch-Template 1.27"
  disable_api_termination = false
  image_id                = "ami-02f7954753fa9a52f"
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = "true"
    delete_on_termination       = "true"
    security_groups             = ["${aws_security_group.eks-dev-3-node-20230120212042472400000009-05b.id}", "${aws_security_group.default-faa.id}"]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      ApplicationName    = "us-east-2-eks-dev-3"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      Cluster            = "eks-dev-3"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      Name               = "eks-dev-3-public-instance"
      ResourceOwner      = "ETI SRE"
      Team               = "eti-sre"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      CustomTag = "ETI SRE EKS volume launch template"
    }
  }
  tag_specifications {
    resource_type = "network-interface"
    tags = {
      CustomTag = "ETI SRE EKS network interface launch template"
    }
  }
  tags = {
    ApplicationName    = "us-east-2-eks-dev-3"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    CustomTag          = "ETI SRE EKS public launch template"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
  user_data = "REDACTED-BY-FIREFLY:a83c94b210b9b71eca0509d4826898b53eb98e5ebe2b4bec1712741cc4d0b62b:sha256"
  # The following attributes are sensitive values redacted by Firefly and should be replaced with your own: [user_data]
  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_iam_role" "eks-dev-3-public-ng-role-20230120213215278600000015-c5a" {
  assume_role_policy  = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EKSNodeAssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
})
  description         = "EKS Managed Public node group IAM role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  tags = {
    ApplicationName    = "us-east-2-eks-dev-3"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}

resource "aws_security_group" "default-faa" {
  description = "default VPC security group"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  ingress {
    from_port = 0
    protocol  = "-1"
    self      = true
    to_port   = 0
  }
  name   = "default"
  vpc_id = "vpc-0805a6b333887a75e"
  # The following attributes have default values introduced when importing the resource into terraform: [revoke_rules_on_delete timeouts]
  lifecycle {
    ignore_changes = [revoke_rules_on_delete, timeouts]
  }
}

resource "aws_security_group" "eks-dev-3-node-20230120212042472400000009-05b" {
  description = "EKS node shared security group"
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Node all egress"
    from_port        = 0
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "-1"
    to_port          = 0
  }
  ingress {
    from_port       = 0
    protocol        = "-1"
    security_groups = ["sg-0607156b95e2a4847", "sg-0732b9b8638bc3140", "sg-0b7740001ea580c9f", "sg-0cc592998db6e9fd2", "sg-0dfb05694f52ceb94"]
    to_port         = 0
  }
  ingress {
    description     = "Cluster API to node 4443/tcp webhook"
    from_port       = 4443
    protocol        = "tcp"
    security_groups = ["sg-0ff94e65f956d00a9"]
    to_port         = 4443
  }
  ingress {
    description     = "Cluster API to node 6443/tcp webhook"
    from_port       = 6443
    protocol        = "tcp"
    security_groups = ["sg-0ff94e65f956d00a9"]
    to_port         = 6443
  }
  ingress {
    description     = "Cluster API to node 8443/tcp webhook"
    from_port       = 8443
    protocol        = "tcp"
    security_groups = ["sg-0ff94e65f956d00a9"]
    to_port         = 8443
  }
  ingress {
    description     = "Cluster API to node 9443/tcp webhook"
    from_port       = 9443
    protocol        = "tcp"
    security_groups = ["sg-0ff94e65f956d00a9"]
    to_port         = 9443
  }
  ingress {
    description     = "Cluster API to node groups"
    from_port       = 443
    protocol        = "tcp"
    security_groups = ["sg-0ff94e65f956d00a9"]
    to_port         = 443
  }
  ingress {
    description     = "Cluster API to node kubelets"
    from_port       = 10250
    protocol        = "tcp"
    security_groups = ["sg-0ff94e65f956d00a9"]
    to_port         = 10250
  }
  ingress {
    description     = "Cluster to node all ports/protocols"
    from_port       = 0
    protocol        = "-1"
    security_groups = ["sg-0ff94e65f956d00a9"]
    to_port         = 0
  }
  ingress {
    description = "Node to node CoreDNS UDP"
    from_port   = 53
    protocol    = "udp"
    self        = true
    to_port     = 53
  }
  ingress {
    description = "Node to node CoreDNS"
    from_port   = 53
    protocol    = "tcp"
    self        = true
    to_port     = 53
  }
  ingress {
    description = "Node to node all ports/protocols"
    from_port   = 0
    protocol    = "-1"
    self        = true
    to_port     = 0
  }
  ingress {
    description = "Node to node ingress on ephemeral ports"
    from_port   = 1025
    protocol    = "tcp"
    self        = true
    to_port     = 65535
  }
  ingress {
    description     = "elbv2.k8s.aws/targetGroupBinding=shared"
    from_port       = 5000
    protocol        = "tcp"
    security_groups = ["sg-0564e881af9cc7020"]
    to_port         = 15051
  }
  tags = {
    ApplicationName                   = "us-east-2-eks-dev-3"
    CiscoMailAlias                    = "eti-sre-admins@cisco.com"
    DataClassification                = "Cisco Confidential"
    DataTaxonomy                      = "Cisco Operations Data"
    EnvironmentName                   = "NonProd"
    Name                              = "eks-dev-3-node"
    ResourceOwner                     = "ETI SRE"
    "kubernetes.io/cluster/eks-dev-3" = "owned"
  }
  vpc_id = "vpc-0805a6b333887a75e"
  # The following attributes have default values introduced when importing the resource into terraform: [revoke_rules_on_delete timeouts]
  lifecycle {
    ignore_changes = [revoke_rules_on_delete, timeouts]
  }
}

resource "aws_eks_node_group" "eks-dev-3-private-nodegroup-58d" {
  ami_type       = "CUSTOM"
  capacity_type  = "ON_DEMAND"
  cluster_name   = "${aws_eks_cluster.eks-dev-3-13e.id}"
  disk_size      = 0
  instance_types = ["m5a.2xlarge"]
  launch_template {
    version = "1"
  }
  node_role_arn   = "${aws_iam_role.eks-dev-3-private-ng-role-20230120213215277300000014-136.arn}"
  release_version = "ami-0a4aa32529d82497d"
  scaling_config {
    desired_size = 6
    max_size     = 8
    min_size     = 4
  }
  subnet_ids = ["${aws_subnet.eks-dev-3-vpc-private-us-east-2c-adf.id}", "${aws_subnet.eks-dev-3-vpc-private-us-east-2b-05c.id}", "${aws_subnet.eks-dev-3-vpc-private-us-east-2a-4e0.id}"]
  tags = {
    ApplicationName    = "us-east-2-eks-dev-3"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    Name               = "eks-dev-3-private-nodegroup"
    ResourceOwner      = "ETI SRE"
  }
  update_config {
    max_unavailable_percentage = 33
  }
  version = "1.27"
}

resource "aws_launch_template" "eks-dev-3-127-private-20231011104642645600000003-318" {
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = "true"
      encrypted             = "true"
      volume_size           = 100
      volume_type           = "gp3"
    }
  }
  default_version         = 1
  description             = "eks-dev-3 Private Launch-Template 1.27"
  disable_api_termination = false
  image_id                = "ami-02f7954753fa9a52f"
  key_name                = "eks-dev-3-eks"
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = "false"
    delete_on_termination       = "true"
    security_groups             = ["${aws_security_group.eks-dev-3-node-20230120212042472400000009-05b.id}", "${aws_security_group.default-faa.id}"]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      ApplicationName    = "us-east-2-eks-dev-3"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      Cluster            = "eks-dev-3"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      Name               = "eks-dev-3-private-instance"
      ResourceOwner      = "ETI SRE"
      Team               = "eti-sre"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      CustomTag = "ETI SRE EKS volume launch template"
    }
  }
  tag_specifications {
    resource_type = "network-interface"
    tags = {
      CustomTag = "ETI SRE EKS network interface launch template"
    }
  }
  tags = {
    ApplicationName    = "us-east-2-eks-dev-3"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    CustomTag          = "ETI SRE EKS private launch template"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
  user_data = "REDACTED-BY-FIREFLY:a83c94b210b9b71eca0509d4826898b53eb98e5ebe2b4bec1712741cc4d0b62b:sha256"
  # The following attributes are sensitive values redacted by Firefly and should be replaced with your own: [user_data]
  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_iam_role" "eks-dev-3-private-ng-role-20230120213215277300000014-136" {
  assume_role_policy  = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EKSNodeAssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
})
  description         = "EKS Managed Private node group IAM role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  tags = {
    ApplicationName    = "us-east-2-eks-dev-3"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}

# resource "aws_key_pair" "eks-dev-3-eks-2f5" {
#   key_name   = "eks-dev-3-eks"
#   public_key = "PUT-VALUE-HERE"
#   tags = {
#     ApplicationName    = "us-east-2-eks-dev-3"
#     CiscoMailAlias     = "eti-sre-admins@cisco.com"
#     DataClassification = "Cisco Confidential"
#     DataTaxonomy       = "Cisco Operations Data"
#     EnvironmentName    = "NonProd"
#     ResourceOwner      = "ETI SRE"
#   }
#   # The following attributes are sensitive values redacted by Firefly and should be replaced with your own: [public_key]
#   lifecycle {
#     ignore_changes = [public_key]
#   }
# }
