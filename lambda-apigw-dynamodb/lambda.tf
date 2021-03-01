resource "aws_lambda_function" "getallusers" {

  function_name = "getallusers"
  memory_size   = 256
  package_type  = "Zip"
  filename      = "functions/userdetails.zip"
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
  role          = aws_iam_role.role_for_Lambda.arn
  handler       = "userdetails.list"
  runtime       = "nodejs12.x"
  environment {
    variables = {
      USER_TABLE = aws_dynamodb_table.usertable.name
    }
  }
}

resource "aws_cloudwatch_log_group" "getallusers" {
  name              = "/aws/lambda/${aws_lambda_function.getallusers.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "apigw_lambda_getallusers" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getallusers.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.userapi.id}/*/${aws_api_gateway_method.getallusers.http_method}${aws_api_gateway_resource.getallusers.path}"
}


resource "aws_lambda_function" "getuser" {

  function_name = "getuser"
  memory_size   = 256
  package_type  = "Zip"
  filename      = "functions/userdetails.zip"
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
  role          = aws_iam_role.role_for_Lambda.arn
  handler       = "userdetails.get"
  runtime       = "nodejs12.x"
  environment {
    variables = {
      USER_TABLE = aws_dynamodb_table.usertable.name
    }
  }
}

resource "aws_cloudwatch_log_group" "getuser" {
  name              = "/aws/lambda/${aws_lambda_function.getuser.function_name}"
  retention_in_days = 30
}


resource "aws_lambda_permission" "apigw_lambda_getuser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getuser.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.userapi.id}/*/${aws_api_gateway_method.getuser.http_method}${aws_api_gateway_resource.getuser.path}"
}

