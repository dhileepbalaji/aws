${jsonencode(
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "iam:*",
                "ec2:*"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": [
		                 for REGION in allowed_regions :	
                             "${REGION}/*"
                    ]
                }
            }
        },
        {
            "Sid": "Denyallactionsonresourcesexceptresourcestaggedwithsandboxastrue",
            "Effect": "Deny",
            "Action": "*",
            "Resource": "*"
            "Condition": {
                "StringNotEquals": { 
                    "aws:ResourceTag/sandbox": "$${aws:PrincipalTag/sandbox}"
                    },
                "StringNotLike": { 
                    "aws:RequestTag/sandbox": "$${aws:PrincipalTag/sandbox}"
                    }
            }
        },
        {
            "Sid": "Denyuntaggingthetagsfromusersandroles",
            "Effect": "Deny",
            "Action": "iam:Untag*",
            "Resource": "*",
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "iam:List*",
                "iam:Get*",
                "iam:Describe*"
            ],
            "Resource": "*"
        }

    ]
}
)}