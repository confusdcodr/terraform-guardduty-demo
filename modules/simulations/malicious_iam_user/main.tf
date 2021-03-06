locals {
  tags = "${merge(var.tags, map("Description","Malicious"))}"
}

resource "aws_iam_user" "compromised" {
  count = "${var.create_malicious_user? 1 : 0}"

  name                 = "${var.project_name}-Compromised-Simulated"
  permissions_boundary = "arn:aws:iam::568850148716:policy/P3PowerUserAccess"
  tags                 = "${merge(local.tags, map("Name", "Malicious User"))}"
}

resource "aws_iam_access_key" "compromised" {
  count = "${var.create_malicious_user? 1 : 0}"

  user = "${aws_iam_user.compromised.name}"
}

resource "aws_iam_user_policy" "compromised" {
  count = "${var.create_malicious_user? 1 : 0}"

  user   = "${aws_iam_user.compromised.id}"
  policy = "${data.template_file.compromised.rendered}"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "template_file" "compromised" {
  template = "${file("modules/simulations/malicious_iam_user/compromised.json")}"

  vars = {
    aws_region = "${data.aws_region.current.name}"
    account_id = "${data.aws_caller_identity.current.account_id}"
  }
}
