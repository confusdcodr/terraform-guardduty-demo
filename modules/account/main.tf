provider "aws" {}

# create the Guard Duty Exceptions table
module "db" {
  source     = "db"
  tags       = "${var.tags}"
  attribute  = "${var.db_attributes}"
  table_name = "ir_exceptions"
}
