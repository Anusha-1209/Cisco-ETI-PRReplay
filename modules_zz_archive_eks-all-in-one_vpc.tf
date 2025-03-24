################################################################################
# data sources
################################################################################

data "aws_availability_zones" "available" {}

################################################################################
# locals
################################################################################

locals {
  vpc_cidr_ab = regex("[0-9]{0,3}.[0-9]{0,3}", var.cidr)
  vpc_name    = "${var.name}-vpc"
  public_subnets = (
    [
      "${local.vpc_cidr_ab}.11.0/24",
      "${local.vpc_cidr_ab}.12.0/24",
      "${local.vpc_cidr_ab}.13.0/24",
    ]
  )

  private_subnets = (
    [
      "${local.vpc_cidr_ab}.1.0/24",
      "${local.vpc_cidr_ab}.2.0/24",
      "${local.vpc_cidr_ab}.3.0/24",
    ]
  )

  len_public_subnets      = length(local.public_subnets)
  len_private_subnets     = length(local.private_subnets)

  azs                     = slice(data.aws_availability_zones.available.names, 0, 3)

  max_subnet_length = max(
    local.len_private_subnets,
    local.len_public_subnets,
  )

}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "vpc" {
  cidr_block            = var.cidr

  instance_tenancy      = var.instance_tenancy
  enable_dns_hostnames  = var.enable_dns_hostnames
  enable_dns_support    = var.enable_dns_support

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.vpc_tags,
  )
}


################################################################################
# Publiс Subnets
################################################################################

resource "aws_subnet" "public" {
  count                                          = local.len_public_subnets
  availability_zone                              = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) > 0 ? element(local.azs, count.index) : null
  availability_zone_id                           = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) == 0 ? element(local.azs, count.index) : null
  cidr_block                                     = element(concat(local.public_subnets, [""]), count.index)
  enable_resource_name_dns_a_record_on_launch    = var.public_subnet_enable_resource_name_dns_a_record_on_launch
  vpc_id                                         = aws_vpc.vpc.id

  tags = merge(
    {
      Name = try(
        var.public_subnet_names[count.index],
        format("${var.name}-${var.public_subnet_suffix}-%s", element(local.azs, count.index))
      )
    },
    var.tags,
    var.public_subnet_tags,
    lookup(var.public_subnet_tags_per_az, element(local.azs, count.index), {})
  )
}

resource "aws_route_table" "public" {
  count = 1
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    { "Name" = "${var.name}-${var.public_subnet_suffix}" },
    var.tags,
    var.public_route_table_tags,
  )
}

resource "aws_route_table_association" "public" {
  count          = local.len_public_subnets
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route" "public_internet_gateway" {
  count                  = 1
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

################################################################################
# Public Network ACLs
################################################################################

resource "aws_network_acl" "public" {
  count      = 1
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = aws_subnet.public[*].id

  tags = merge(
    { "Name" = "${var.name}-${var.public_subnet_suffix}" },
    var.tags,
    var.public_acl_tags,
  )
}

resource "aws_network_acl_rule" "public_inbound" {
  count           = length(var.public_inbound_acl_rules)
  network_acl_id  = aws_network_acl.public[0].id

  egress          = false
  rule_number     = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.public_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count           = length(var.public_outbound_acl_rules)
  network_acl_id  = aws_network_acl.public[0].id

  egress          = true
  rule_number     = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.public_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

################################################################################
# Private Subnets
################################################################################

resource "aws_subnet" "private" {
  count                                          = local.len_private_subnets
  availability_zone                              = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) > 0 ? element(local.azs, count.index) : null
  availability_zone_id                           = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) == 0 ? element(local.azs, count.index) : null
  cidr_block                                     = element(concat(local.private_subnets, [""]), count.index)
  enable_resource_name_dns_a_record_on_launch    = var.private_subnet_enable_resource_name_dns_a_record_on_launch
  vpc_id                                         = aws_vpc.vpc.id

  tags = merge(
    {
      Name = try(
        var.private_subnet_names[count.index],
        format("${var.name}-${var.private_subnet_suffix}-%s", element(local.azs, count.index))
      )
    },
    var.tags,
    var.private_subnet_tags,
    lookup(var.private_subnet_tags_per_az, element(local.azs, count.index), {})
  )
}

# There are as many routing tables as the number of NAT gateways
resource "aws_route_table" "private" {
  count   = 1
  vpc_id  = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = var.single_nat_gateway ? "${var.name}-${var.private_subnet_suffix}" : format(
        "${var.name}-${var.private_subnet_suffix}-%s",
        element(local.azs, count.index),
      )
    },
    var.tags,
    var.private_route_table_tags,
  )
}

resource "aws_route_table_association" "private" {
  count          = local.len_private_subnets

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(
    aws_route_table.private[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

################################################################################
# Private Network ACLs
################################################################################

resource "aws_network_acl" "private" {
  count      = 1
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = aws_subnet.private[*].id

  tags = merge(
    { "Name" = "${var.name}-${var.private_subnet_suffix}" },
    var.tags,
    var.private_acl_tags,
  )
}

resource "aws_network_acl_rule" "private_inbound" {
  count = length(var.private_inbound_acl_rules)
  network_acl_id = aws_network_acl.private[0].id

  egress          = false
  rule_number     = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.private_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = length(var.private_outbound_acl_rules)
  network_acl_id = aws_network_acl.private[0].id

  egress          = true
  rule_number     = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.private_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}


################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count  = 1
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.igw_tags,
  )
}

resource "aws_egress_only_internet_gateway" "this" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.igw_tags,
  )
}

################################################################################
# NAT Gateway
################################################################################

locals {
  nat_gateway_count = 1
  nat_gateway_ips   = try(aws_eip.nat[*].id, [])
}

resource "aws_eip" "nat" {
  count = local.nat_gateway_count
  domain = "vpc"

  tags = merge(
    {
      "Name" = format(
        "${var.name}-%s",
        element(local.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_eip_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )
  tags = merge(
    {
      "Name" = format(
        "${var.name}-%s",
        element(local.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  count                  = 1
  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}