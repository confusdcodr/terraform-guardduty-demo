provider "aws" {
  region = "${var.region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

locals {
  create_exceptions_table   = true
  create_malicious_user     = false
  create_malicious_instance = false
  create_cloudtrail         = true
  create_vpc_flow_logs      = true

  vpc_id = "vpc-9241cef5"
}

module "cloudtrail" {
  source = "modules/cloudtrail"

  create_cloudtrail = "${local.create_cloudtrail}"
  project_name      = "${var.project_name}"
}

module "vpc_flow_logs" {
  source = "modules/vpc_flow_logs"

  create_vpc_flow_logs = "${local.create_vpc_flow_logs}"
  project_name         = "${var.project_name}"
  vpc_id               = "${local.vpc_id}"
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
