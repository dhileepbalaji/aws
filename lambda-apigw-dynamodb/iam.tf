locals {
    dynamodb_access_policy = templatefile("policy_templates/dynamodb_access_policy.tmpl", {
      TABLENAME = aws_dynamodb_table.usertable.arn
  })
   cloudwatch_access_policy = templatefile("policy_templates/cloudwatch_policy.tmpl", {
       DUMMY = "dummy"
   })
   lambda_assume_role_policy = templatefile("policy_templates/lambda_assume_role_policy.tmpl", {
       DUMMY = "dummy"  
   })

}


resource "aws_iam_role_policy" "dynamodb_access_policy" {
  name = "dynamodb_access_policy"
  role = aws_iam_role.role_for_Lambda.id

  policy = local.dynamodb_access_policy
}


resource "aws_iam_role_policy" "cloudwatch_access_policy" {
  name = "cloudwatch_access_policy"
  role = aws_iam_role.role_for_Lambda.id

  policy = local.cloudwatch_access_policy
}


resource "aws_iam_role" "role_for_Lambda" {
  name = "Lambda_DynamoDB"

  assume_role_policy = local.lambda_assume_role_policy

}


