provider "aws" {
  region = "${var.region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

module "db" {
  source = "modules/remediation_db"

  create_exceptions_table = "${var.create_exceptions_table}"

  attributes = "${var.db_attributes}"

  table_name = "${var.table_name}"
  region     = "${var.region}"
}

module "malicious_user" {
  source = "modules/simulations/malicious_iam_user"

  resource_name         = "${var.resource_name}"
  create_malicious_user = "${var.create_malicious_user}"
}

module "malicious_instance" {
  source = "modules/simulations/malicious_instance"

  resource_name             = "${var.resource_name}"
  create_malicious_instance = "${var.create_malicious_instance}"
  instance_type             = "t2.micro"
}
