provider "aws" {
  region = "${var.region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

module "cloudtrail" {
  source = "modules/cloudtrail"

  create_cloudtrail = "${var.create_cloudtrail}"
  project_name      = "${var.project_name}"
}

module "vpc_flow_logs" {
  source = "modules/vpc_flow_logs"

  create_vpc_flow_logs = "${var.create_vpc_flow_logs}"
  project_name         = "${var.project_name}"
  vpc_id               = "${var.vpc_id}"
}

module "db" {
  source = "modules/remediation_db"

  create_exceptions_table = "${var.create_exceptions_table}"

  attributes = "${var.db_attributes}"

  table_name = "${var.table_name}"
  region     = "${var.region}"
}

module "malicious_iam_user" {
  source = "modules/simulations/malicious_iam_user"

  project_name          = "${var.project_name}"
  create_malicious_user = "${var.create_malicious_iam_user}"
}

module "malicious_instance" {
  source = "modules/simulations/malicious_instance"

  project_name              = "${var.project_name}"
  create_malicious_instance = "${var.create_malicious_instance}"
  instance_type             = "t2.micro"
  key_pair_name             = "${var.key_pair_name}"
  permissions_boundary_arn  = "${var.permissions_boundary_arn}"

  #depends_on = ["module.app_server_linux", "module.app_server_windows"]
}

module "app_server_linux" {
  source = "modules/simulations/app_server_linux"

  project_name             = "${var.project_name}"
  create_app_server_linux  = "${var.create_app_server_linux}"
  instance_type            = "t2.micro"
  key_pair_name            = "${var.key_pair_name}"
  vpc_id                   = "${var.vpc_id}"
  cidr_block               = "${var.cidr_block}"
  permissions_boundary_arn = "${var.permissions_boundary_arn}"
}

module "app_server_windows" {
  source = "modules/simulations/app_server_windows"

  project_name              = "${var.project_name}"
  create_app_server_windows = "${var.create_app_server_windows}"
  instance_type             = "t2.micro"
  vpc_id                    = "${var.vpc_id}"
  cidr_block                = "${var.cidr_block}"
  permissions_boundary_arn  = "${var.permissions_boundary_arn}"
}

#module "guard_duty" {
#  source = "modules/guard_duty"
#
#  project_name = "${var.project_name}"
#}

