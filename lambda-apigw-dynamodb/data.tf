data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "functions/userdetails.js"
  output_path = "functions/userdetails.zip"
}
