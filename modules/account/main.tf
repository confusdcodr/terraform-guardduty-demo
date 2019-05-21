provider "aws" {
  region = "${var.region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

locals {
  create_exceptions_table   = true
  create_malicious_user     = true
  create_malicious_instance = true
  create_app_server_windows = true
  create_app_server_linux   = true
  create_cloudtrail         = true
  create_vpc_flow_logs      = true

  vpc_id        = "vpc-9241cef5"
  key_pair_name = "gowens-intern"
  cidr_block = "172.31.0.0/16"
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
  source = "modules/simulations/malicious_user"

  project_name         = "${var.project_name}"
  create_malicious_user = "${local.create_malicious_user}"
}

module "malicious_instance" {
  source = "modules/simulations/malicious_instance"

  project_name             = "${var.project_name}"
  create_malicious_instance = "${local.create_malicious_instance}"
  instance_type             = "t2.micro"
  key_pair_name             = "${local.key_pair_name}"
  permissions_boundary_arn  = "${var.permissions_boundary_arn}"
}

module "app_server_linux" {
  source = "modules/simulations/app_server_linux"

  project_name           = "${var.project_name}"
  create_app_server_linux = "${local.create_app_server_linux}"
  instance_type           = "t2.micro"
  key_pair_name           = "${local.key_pair_name}"
  vpc_id                  = "${local.vpc_id}"
  cidr_block              = "${local.cidr_block}"
}

module "app_server_windows" {
  source = "modules/simulations/app_server_windows"

  project_name             = "${var.project_name}"
  create_app_server_windows = "${local.create_app_server_windows}"
  instance_type             = "t2.micro"
  vpc_id                    = "${local.vpc_id}"
  cidr_block                = "${local.cidr_block}"
}

module "guard_duty" {
  source = "modules/guard_duty"

  project_name = "${var.project_name}"
}
