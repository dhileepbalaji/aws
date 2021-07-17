${jsonencode(
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*",
            "Condition": {
                "ForAnyValue:StringLike": {
                    "ec2:InstanceType": [
                        "*.nano",
                        "*.small",
                        "*.micro",
                        "*.medium"
                    ]
                }
            }
        },
        {
            "Sid": "",
            "Effect": "Deny",
            "Action": [
                "s3:PutBucketPublicAccessBlock",
                "s3:PutAccountPublicAccessBlock",
                "iam:UpdateAccountPasswordPolicy",
                "iam:DeleteUserPermissionsBoundary",
                "iam:DeleteRolePermissionsBoundary",
                "iam:DeleteAccountPasswordPolicy",
                "es:*",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Deny",
            "NotAction": [
                "iam:List*",
                "iam:Get*",
                "iam:Describe*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Deny",
            "Action": [
                "iam:PutUserPolicy",
                "iam:PutUserPermissionsBoundary",
                "iam:PutRolePolicy",
                "iam:PutRolePermissionsBoundary",
                "iam:DetachUserPolicy",
                "iam:DetachRolePolicy",
                "iam:DeleteUserPolicy",
                "iam:DeleteRolePolicy",
                "iam:CreateUser",
                "iam:CreateRole",
                "iam:AttachUserPolicy",
                "iam:AttachRolePolicy"
            ],
            "Resource": "*",
        }
    ]
}
)}