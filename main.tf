provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "exceptions_table" {
  name           = "ir_exceptions"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "rule"
  range_key      = "account_id"

  attribute = [
    {
      name = "rule"
      type = "S"
    },
    {
      name = "account_id"
      type = "S"
    }
  ]

  tags = {
    Project = "automated-ir"
  }
}
