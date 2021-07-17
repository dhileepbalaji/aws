${jsonencode(
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowlistactionstoworkonConsole",
            "Effect": "Allow",
            "Action": [
                "iam:List*",
                "iam:Get*",
                "iam:Describe*",
                "s3:Get*",
                "s3:List*"

            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowactionsonAllowedRegions",
            "Effect": "Allow",
            "Action": [
                "ec2:Get*",
                "ec2:Describe*"
            ],
            "Resource": "*"
            "Condition": {
                "StringLike": {
                    "aws:RequestedRegion": [
		                 for REGION in allowed_regions :	
                             "${REGION}"
                    ]
                }
            }
        },
        {
            "Sid": "AllowAllActionsOnRequestTagwithSandboxAsTrue",
            "Effect": "Allow",
            "NotAction": [
                "ec2:Get*",
                "ec2:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                 "StringEquals": { 
                    "ec2:ResourceTag/sandboxuser": "true"
                    }               
            }
        },
         {
            "Sid": "Denyuntaggingthetagsfromusersandroles",
            "Effect": "Deny",
            "Action": "iam:Untag*",
            "Resource": "*",
        }
    ]
}
)}