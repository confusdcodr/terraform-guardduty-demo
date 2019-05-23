####################################
# Key Pair
####################################

locals {
  key_pair_specified      = "${var.key_pair_name == ""}"
  key_pair_write          = "${local.key_pair_specified && var.write_private_key}"
  generated_key_pair_name = "${var.project_name}-malicious-instance"
  key_pair_name           = "${ local.key_pair_specified ? local.generated_key_pair_name : var.key_pair_name }"
  key_pair_path           = "${path.module}/generated"

  tags = "${merge(var.tags, map("Description","Malicious"))}"
}

data "aws_caller_identity" "current" {}

resource "tls_private_key" "this" {
  count = "${var.create_malicious_instance && local.key_pair_specified ? 1 : 0}"

  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "this" {
  count = "${var.create_malicious_instance && local.key_pair_specified ? 1 : 0}"

  key_name   = "${local.key_pair_name}"
  public_key = "${tls_private_key.this.public_key_openssh}"
}

resource "local_file" "private_key" {
  count = "${var.create_malicious_instance && local.key_pair_write ? 1 : 0}"

  content  = "${tls_private_key.this.private_key_pem}"
  filename = "${local.key_pair_path}/${local.key_pair_name}.pem"
}

resource "null_resource" "chmod_key" {
  count = "${local.key_pair_write ? 1 : 0}"

  depends_on = ["local_file.private_key"]

  provisioner "local-exec" {
    command = "chmod 600 ${local.key_pair_path}/${local.key_pair_name}.pem"
  }
}

resource "aws_iam_role" "this" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  name                  = "MaliciousInstanceRole"
  description           = "Role attached to the Malicious instance profile"
  assume_role_policy    = "${data.aws_iam_policy_document.trust.json}"
  force_detach_policies = true
  max_session_duration  = "43200"
  tags                  = "${local.tags}"
  permissions_boundary  = "${var.permissions_boundary_arn}"
}

resource "aws_iam_policy" "this" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  name   = "MaliciousInstancePolicy"
  policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_iam_instance_profile" "this" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  name = "MaliciousInstanceProfile"
  role = "${aws_iam_role.this.id}"
}

resource "aws_iam_policy_attachment" "this" {
  name       = "MaliciousInstancePolicyAttachment"
  roles      = ["${aws_iam_role.this.name}"]
  policy_arn = "${aws_iam_policy.this.arn}"
}

data "aws_region" "current" {}

# get the latest amazon linux AMI
data "aws_ami" "amazon_linux" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "template_file" "trust" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  template = "${file("modules/simulations/malicious_instance/iam/trust.json")}"
}

# create the instance profile
data "template_file" "policy" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  template = "${file("modules/simulations/malicious_instance/iam/policy.json")}"
}

# format the instance userdata
data "template_file" "userdata" {
  template = "${file("modules/simulations/malicious_instance/user_data.tpl")}"

  vars = {
    target_region = "${data.aws_region.current.name}"
  }
}

data "aws_iam_policy_document" "trust" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  source_json = "${data.template_file.trust.rendered}"
}

data "aws_iam_policy_document" "policy" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  source_json = "${data.template_file.policy.rendered}"
}

# create the instance
resource "aws_instance" "compromised" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "${var.instance_type}"
  private_ip             = "${var.private_ip}"
  user_data              = "${data.template_file.userdata.rendered}"
  iam_instance_profile   = "${aws_iam_instance_profile.this.name}"
  key_name               = "${local.key_pair_name}"
  vpc_security_group_ids = ["${var.target_sg}"]

  tags = "${merge(local.tags, map("Name", "Malicious Instance"))}"
}
