resource "aws_api_gateway_rest_api" "userapi" {
  name        = "userapi"
  description = "Terraform User Api Example"
}
# Create api stage and deployment resources
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.dev.id
  rest_api_id   = aws_api_gateway_rest_api.userapi.id
  stage_name    = "dev"

}

resource "aws_api_gateway_deployment" "dev" {
  depends_on = [
        aws_api_gateway_method.getallusers,
        aws_api_gateway_integration.getallusers,
        aws_api_gateway_method.getuser,
        aws_api_gateway_integration.getuser
      ]
  rest_api_id = aws_api_gateway_rest_api.userapi.id

  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.prod.id
  rest_api_id   = aws_api_gateway_rest_api.userapi.id
  stage_name    = "prod"
}

resource "aws_api_gateway_deployment" "prod" {
  depends_on = [
        aws_api_gateway_method.getallusers,
        aws_api_gateway_integration.getallusers,
        aws_api_gateway_method.getuser,
        aws_api_gateway_integration.getuser
      ]
  rest_api_id = aws_api_gateway_rest_api.userapi.id

  lifecycle {
    create_before_destroy = true
  }
}

# Create actual api resources

resource "aws_api_gateway_resource" "getallusers" {
   rest_api_id = aws_api_gateway_rest_api.userapi.id
   parent_id   = aws_api_gateway_rest_api.userapi.root_resource_id
   path_part   = "id"
}

resource "aws_api_gateway_method" "getallusers" {
   rest_api_id   = aws_api_gateway_rest_api.userapi.id
   resource_id   = aws_api_gateway_resource.getallusers.id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "getallusers" {
   rest_api_id = aws_api_gateway_rest_api.userapi.id
   resource_id = aws_api_gateway_method.getallusers.resource_id
   http_method = aws_api_gateway_method.getallusers.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.getallusers.invoke_arn
}


resource "aws_api_gateway_resource" "getuser" {
   rest_api_id = aws_api_gateway_rest_api.userapi.id
   parent_id   = aws_api_gateway_resource.getallusers.id
   path_part   = "{userid}"
}

resource "aws_api_gateway_method" "getuser" {
   rest_api_id   = aws_api_gateway_rest_api.userapi.id
   resource_id   = aws_api_gateway_resource.getuser.id
   http_method   = "GET"
   authorization = "NONE"
}


resource "aws_api_gateway_integration" "getuser" {
   rest_api_id   = aws_api_gateway_rest_api.userapi.id
   resource_id = aws_api_gateway_method.getuser.resource_id
   http_method = aws_api_gateway_method.getuser.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.getuser.invoke_arn
}