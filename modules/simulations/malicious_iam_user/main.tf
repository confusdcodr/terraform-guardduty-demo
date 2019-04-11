locals {
  tags = {
    Description = "Resources for guard duty finding simulation"
  }
}

resource "aws_iam_user" "compromised" {
  name = "${var.resource_name}-Compromised-Simulated"
  tags = "${local.tags}"
}

resource "aws_iam_access_key" "compromised" {
  user = "${aws_iam_user.compromised.name}"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "template_file" "compromised" {
  template = "${file("compromised.policy")}"

  vars = {
    aws_region = "${data.aws_region.current.name}"
    account_id = "${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_iam_user_policy" "compromised" {
  policy = "${data.template_file.compromised.rendered}"
}
