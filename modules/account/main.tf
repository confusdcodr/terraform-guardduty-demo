provider "aws" {
  region = "${var.region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

locals {
  create_exceptions_table = true
  create_malicious_user = false
  create_malicious_instance = false

  create_cloudtrail = true
}

module "cloudtrail" {
  source = "modules/cloudtrail"

  create_cloudtrail = "${local.create_cloudtrail}"
  project_name = "${var.project_name}"
}

module "db" {
  source = "modules/remediation_db"

  create_exceptions_table = "${local.create_exceptions_table}"

  attributes = "${var.db_attributes}"

  table_name = "${var.table_name}"
  region     = "${var.region}"
}

module "malicious_user" {
  source = "modules/simulations/malicious_iam_user"

  resource_name         = "${var.resource_name}"
  create_malicious_user = "${local.create_malicious_user}"
}

module "malicious_instance" {
  source = "modules/simulations/malicious_instance"

  resource_name             = "${var.resource_name}"
  create_malicious_instance = "${local.create_malicious_instance}"
  instance_type             = "t2.micro"
}
