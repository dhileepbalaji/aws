output "dev_url" {
  value = aws_api_gateway_stage.dev.invoke_url
}
output "prod_url" {
  value = aws_api_gateway_stage.prod.invoke_url
}