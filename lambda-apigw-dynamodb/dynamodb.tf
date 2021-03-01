resource "aws_dynamodb_table" "usertable" {
  name           = "Usertable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "N"
  }


  tags = {
    Name        = "dynamodb-Usertable-1"
    Environment = "development"
  }


}


resource "null_resource" "loaddatatodb" {
  depends_on = [aws_dynamodb_table.usertable]
  provisioner "local-exec" {
    command = "bash loaddata.sh"
  }
}