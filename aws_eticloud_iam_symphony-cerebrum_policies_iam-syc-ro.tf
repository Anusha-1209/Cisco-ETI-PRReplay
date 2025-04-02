resource "aws_iam_policy" "iam-syc-ro" {
  name        = "iam-syc-ro"
  path        = "/"
  description = "IAM read-only access for symphony-cerebrum"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "iam:GetPolicyVersion",
          "iam:GetAccountPasswordPolicy",
          "iam:ListRoleTags",
          "iam:ListServerCertificates",
          "iam:GenerateServiceLastAccessedDetails",
          "iam:ListServiceSpecificCredentials",
          "iam:ListSigningCertificates",
          "iam:ListVirtualMFADevices",
          "iam:ListSSHPublicKeys",
          "iam:SimulateCustomPolicy",
          "iam:SimulatePrincipalPolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListOpenIDConnectProviderTags",
          "iam:ListSAMLProviderTags",
          "iam:ListRolePolicies",
          "iam:GetAccountAuthorizationDetails",
          "iam:GetCredentialReport",
          "iam:ListPolicies",
          "iam:GetServerCertificate",
          "iam:GetRole",
          "iam:ListSAMLProviders",
          "iam:GetPolicy",
          "iam:GetAccessKeyLastUsed",
          "iam:ListEntitiesForPolicy",
          "iam:GetUserPolicy",
          "iam:ListGroupsForUser",
          "iam:GetGroupPolicy",
          "iam:GetOpenIDConnectProvider",
          "iam:GetRolePolicy",
          "iam:GetAccountSummary",
          "iam:GenerateCredentialReport",
          "iam:GetServiceLastAccessedDetailsWithEntities",
          "iam:ListPoliciesGrantingServiceAccess",
          "iam:ListInstanceProfileTags",
          "iam:ListMFADevices",
          "iam:GetServiceLastAccessedDetails",
          "iam:GetGroup",
          "iam:GetContextKeysForPrincipalPolicy",
          "iam:GetOrganizationsAccessReport",
          "iam:GetServiceLinkedRoleDeletionStatus",
          "iam:ListInstanceProfilesForRole",
          "iam:GenerateOrganizationsAccessReport",
          "iam:ListAttachedUserPolicies",
          "iam:ListAttachedGroupPolicies",
          "iam:ListPolicyTags",
          "iam:GetSAMLProvider",
          "iam:ListAccessKeys",
          "iam:GetInstanceProfile",
          "iam:ListGroupPolicies",
          "iam:GetSSHPublicKey",
          "iam:ListRoles",
          "iam:ListUserPolicies",
          "iam:ListInstanceProfiles",
          "iam:GetContextKeysForCustomPolicy",
          "iam:ListPolicyVersions",
          "iam:ListOpenIDConnectProviders",
          "iam:ListServerCertificateTags",
          "iam:ListAccountAliases",
          "iam:ListUsers",
          "iam:GetUser",
          "iam:ListGroups",
          "iam:ListMFADeviceTags",
          "iam:GetLoginProfile",
          "iam:ListUserTags"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    Name = "iam-syc-ro"
  }
}
