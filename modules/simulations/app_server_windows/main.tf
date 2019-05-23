locals {
  tags = {
    Description = "Windows App Server for use with Guard Duty testing"
  }
}

# Create IAM Role
resource "aws_iam_role" "this" {
  count = "${var.create_app_server_windows? 1 : 0 }"

  name                  = "AppServerWindowsRole"
  description           = "Role attached to the AppServer instance profile"
  assume_role_policy    = "${data.aws_iam_policy_document.trust.json}"
  force_detach_policies = true
  max_session_duration  = "43200"
  tags                  = "${local.tags}"
  permissions_boundary  = "${var.permissions_boundary_arn}"
}

# Create IAM Policy
resource "aws_iam_policy" "this" {
  count = "${var.create_app_server_windows? 1 : 0 }"

  name   = "AppServerWindowsPolicy"
  policy = "${data.aws_iam_policy_document.policy.json}"
}

# Create IAM Instance Profile (this is for EC2)
resource "aws_iam_instance_profile" "this" {
  count = "${var.create_app_server_windows? 1 : 0 }"

  name = "AppServerWindowsInstanceProfile"
  role = "${aws_iam_role.this.id}"
}

# Attach IAM Policy to IAM Role
resource "aws_iam_policy_attachment" "this" {
  name       = "AppServerWindowsPolicyAttachment"
  roles      = ["${aws_iam_role.this.name}"]
  policy_arn = "${aws_iam_policy.this.arn}"
}

resource "aws_security_group" "this" {
  description = "Allow inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_block}"]
  }
}

# create the instance
resource "aws_instance" "this" {
  count = "${var.create_app_server_windows? 1 : 0 }"

  ami                    = "${data.aws_ami.this.id}"
  instance_type          = "${var.instance_type}"
  private_ip             = "${var.private_ip}"
  iam_instance_profile   = "${aws_iam_instance_profile.this.name}"
  vpc_security_group_ids = ["${aws_security_group.this.id}"]

  tags = "${merge(local.tags, map("Name", "Windows App Server"))}"
}

data "aws_region" "current" {}

# get the latest Windows AMI
data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "template_file" "trust" {
  count = "${var.create_app_server_windows? 1 : 0 }"

  template = "${file("modules/simulations/app_server_windows/iam/trust.json")}"
}

# create the instance profile
data "template_file" "policy" {
  count = "${var.create_app_server_windows? 1 : 0 }"

  template = "${file("modules/simulations/app_server_windows/iam/policy.json")}"
}

data "aws_iam_policy_document" "trust" {
  count = "${var.create_app_server_windows? 1 : 0 }"

  source_json = "${data.template_file.trust.rendered}"
}

data "aws_iam_policy_document" "policy" {
  count = "${var.create_app_server_windows? 1 : 0 }"

  source_json = "${data.template_file.policy.rendered}"
}
