resource "aws_ec2_managed_prefix_list" "cisco_internal_cidrs" {
  name           = "Cisco Internal CIDRs"
  address_family = "IPv4"
  max_entries    = length(var.cisco_cidrs)
}

resource "aws_ec2_managed_prefix_list_entry" "entry" {
  count          = length(var.cisco_cidrs)
  cidr           = var.cisco_cidrs[count.index]
  prefix_list_id = aws_ec2_managed_prefix_list.cisco_internal_cidrs.id
}