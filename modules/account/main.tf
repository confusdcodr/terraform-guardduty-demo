provider "aws" {
  region = "${var.region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

########################################
# Configure Guard Duty
########################################
resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}

resource "random_string" "rnd" {
  length  = 8
  special = false
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "this" {
  acl    = "private"
  bucket = "tf-ipset-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_object" "this" {
  acl     = "public-read"
  content = "${var.cidr_block}"

  bucket = "${aws_s3_bucket.this.id}"
  key    = "MyThreatIntelSet"
}

resource "aws_guardduty_threatintelset" "this" {
  activate    = true
  detector_id = "${aws_guardduty_detector.this.id}"
  format      = "TXT"
  location    = "https://s3.amazonaws.com/${aws_s3_bucket_object.this.bucket}/${aws_s3_bucket_object.this.key}"
  name        = "MyThreatIntelSet-${random_string.rnd.result}"
}

########################################
# Configure Additional Modules
########################################
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

  tags                      = "${var.tags}"
  project_name              = "${var.project_name}"
  create_malicious_instance = "${var.create_malicious_instance}"
  instance_type             = "t2.micro"
  key_pair_name             = "${var.key_pair_name}"
  permissions_boundary_arn  = "${var.permissions_boundary_arn}"
  target_sg                 = "${aws_security_group.malicious_instance.id}"
  guarddty_obj_location     = "${aws_s3_bucket_object.this.bucket}"
  guardduty_ip_list_object  = "${aws_s3_bucket_object.this.key}"

  #depends_on = ["module.app_server_linux", "module.app_server_windows"]
}

module "app_server_linux" {
  source = "modules/simulations/app_server_linux"

  tags                     = "${var.tags}"
  project_name             = "${var.project_name}"
  create_app_server_linux  = "${var.create_app_server_linux}"
  instance_type            = "t2.micro"
  key_pair_name            = "${var.key_pair_name}"
  vpc_id                   = "${var.vpc_id}"
  cidr_block               = "${var.cidr_block}"
  permissions_boundary_arn = "${var.permissions_boundary_arn}"
  target_sg                = "${aws_security_group.linux_app_server.id}"
}

module "app_server_windows" {
  source = "modules/simulations/app_server_windows"

  tags                      = "${var.tags}"
  create_app_server_windows = "${var.create_app_server_windows}"
  instance_type             = "t2.micro"
  vpc_id                    = "${var.vpc_id}"
  cidr_block                = "${var.cidr_block}"
  permissions_boundary_arn  = "${var.permissions_boundary_arn}"
  target_sg                 = "${aws_security_group.windows_app_server.id}"
}
