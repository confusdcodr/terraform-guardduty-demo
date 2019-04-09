provider "aws" {}

# create the Guard Duty Exceptions table
module "db" {
  source     = "db"
  tags       = "${var.tags}"
  attribute  = "${var.db_attributes}"
  table_name = "ir_exceptions"
}

module "malicious_user" {
  source = "simulations/malicious_user"

  resource_name         = "${var.resource_name}"
  create_malicious_user = "${var.create_malicious_user}"
}

module "malicious_instance" {
  source = "simulations/malicious_instance"

  resource_name             = "${var.resource_name}"
  create_malicious_instance = "${var.create_malicious_instance}"
}
