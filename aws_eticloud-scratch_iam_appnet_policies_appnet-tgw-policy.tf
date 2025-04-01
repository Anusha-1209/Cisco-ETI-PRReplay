resource aws_iam_policy "appnet-tgw-policy" {
	name = "appnet-tgw-policy"
	description = "Allow appnet to manipulate the Transit Gateway"
	policy = jsonencode(
        {
            Statement = [
                {
                    Action   = [
                        "ec2:DeleteTransitGatewayRouteTable",
                        "ec2:CreateTransitGatewayRoute",
                        "ec2:DeleteTransitGatewayRoute",
                        "ram:ListResourceSharePermissions",
                        "ec2:CreateTransitGatewayVpcAttachment",
                        "ec2:DeleteTransitGatewayVpcAttachment",
                        "ec2:CreateRoute",
                        "ec2:CreateTransitGatewayRouteTable",
                        "ec2:DeleteRoute",
                        "ec2:CreateTransitGateway",
                        "ec2:DeleteTransitGateway",
                        "ec2:ReplaceRoute",
                    ]
                    Effect   = "Allow"
                    Resource = [
                        "arn:aws:ec2:*:380642323071:route-table/*",
                        "arn:aws:ec2:*:380642323071:vpc/*",
                        "arn:aws:ec2:*:380642323071:transit-gateway-attachment/*",
                        "arn:aws:ec2:*:380642323071:subnet/*",
                        "arn:aws:ec2:*:380642323071:transit-gateway-route-table/*",
                        "arn:aws:ec2:*:380642323071:transit-gateway/*",
                        "arn:aws:ram:us-east-2:380642323071:resource-share/*",
                    ]
                    Sid      = "VisualEditor0"
                },
                {
                    Action   = [
                        "ec2:DeleteTags",
                        "ec2:CreateTags",
                        "ec2:ExportClientVpnClientConfiguration",
                        "ec2:GetTransitGatewayAttachmentPropagations",
                        "ec2:GetGroupsForCapacityReservation",
                        "ec2:GetTransitGatewayPrefixListReferences",
                        "ec2:ExportClientVpnClientCertificateRevocationList",
                        "ram:GetPermission",
                        "ec2:SearchTransitGatewayRoutes",
                        "ec2:SearchLocalGatewayRoutes",
                        "ec2:GetTransitGatewayRouteTablePropagations",
                        "ram:ListPendingInvitationResources",
                        "ec2:GetTransitGatewayMulticastDomainAssociations",
                        "ec2:SearchTransitGatewayMulticastGroups",
                        "ec2:GetTransitGatewayRouteTableAssociations",
                    ]
                    Effect   = "Allow"
                    Resource = [
                        "arn:aws:ram::380642323071:permission/*",
                        "arn:aws:ram:*:380642323071:resource-share-invitation/*",
                        "arn:aws:ec2:*:380642323071:transit-gateway-attachment/*",
                        "arn:aws:ec2:*:380642323071:transit-gateway-route-table/*",
                        "arn:aws:ec2:*:380642323071:transit-gateway-multicast-domain/*",
                        "arn:aws:ec2:*:380642323071:local-gateway-route-table/*",
                        "arn:aws:ec2:*:380642323071:capacity-reservation/*",
                        "arn:aws:ec2:*:380642323071:client-vpn-endpoint/*",
                    ]
                    Sid      = "VisualEditor1"
                },
                {
                    Action   = [
                        "ram:ListResources",
                        "ram:ListPermissions",
                        "ram:GetResourceShares",
                        "iam:CreateServiceLinkedRole",
                        "networkmanager:*",
                        "ram:ListResourceTypes",
                        "ram:ListPrincipals",
                        "ram:GetResourceShareAssociations",
                        "ec2:*",
                        "ram:GetResourcePolicies",
                        "ram:GetResourceShareInvitations",
                    ]
                    Effect   = "Allow"
                    Resource = "*"
                    Sid      = "VisualEditor2"
                },
            ]
            Version   = "2012-10-17"
        }
    )
	tags = var.tags
}
