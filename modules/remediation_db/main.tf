locals {
  additional_tags = {
    Description = "Table to hold Guard Duty Exceptions"
  }
}

resource "aws_dynamodb_table" "exceptions_table" {
  count = "${var.create_exceptions_table ? 1 : 0}"

  name           = "${var.table_name}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "rule"
  range_key      = "account_id"

  attribute = "${var.attributes}"

  tags = "${merge(var.tags, local.additional_tags)}"
}
