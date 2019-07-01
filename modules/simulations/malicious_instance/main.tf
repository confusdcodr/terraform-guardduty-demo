####################################
# Key Pair
####################################

locals {
  tags = "${merge(var.tags, map("Description","Malicious"))}"
}

data "aws_caller_identity" "current" {}

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
    target_region            = "${data.aws_region.current.name}"
    guarddty_obj_location    = "${var.guarddty_obj_location}"
    guardduty_ip_list_object = "${var.guardduty_ip_list_object }"
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
#resource "aws_instance" "compromised" {
#  count = "${var.create_malicious_instance ? 1 : 0 }"
#
#  ami                    = "${data.aws_ami.amazon_linux.id}"
#  instance_type          = "${var.instance_type}"
#  private_ip             = "${var.private_ip}"
#  user_data              = "${data.template_file.userdata.rendered}"
#  iam_instance_profile   = "${aws_iam_instance_profile.this.name}"
#  key_name               = "${local.key_pair_name}"
#  vpc_security_group_ids = ["${var.target_sg}"]
#
#  tags = "${merge(local.tags, map("Name", "Malicious Instance"))}"
#}

resource "aws_launch_configuration" "this" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  image_id             = "${data.aws_ami.amazon_linux.id}"
  instance_type        = "${var.instance_type}"
  user_data            = "${data.template_file.userdata.rendered}"
  security_groups      = ["${var.target_sg}"]
  iam_instance_profile = "${aws_iam_instance_profile.this.name}"
  key_name             = "${var.key_pair_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  name                 = "malicious-asg"
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.this.name}"
  vpc_zone_identifier  = "${var.subnet_ids}"

  lifecycle {
    create_before_destroy = true
  }

  tags = ["${concat(
      list(map("key", "Name", "value", "Malicious Instance", "propagate_at_launch", true))
   )}"]
}

resource "aws_autoscaling_schedule" "scaledown" {
  scheduled_action_name = "afterhours-scaledown"
  min_size              = 0
  max_size              = 1
  desired_capacity      = 0

  # in UTC. +4 hours to EST
  # scale down at 1900 EST every day
  recurrence = "0 23 * * *"

  autoscaling_group_name = "${aws_autoscaling_group.this.name}"
}

resource "aws_autoscaling_schedule" "scaleup" {
  scheduled_action_name = "workinghours-scaleup"
  min_size              = 1
  max_size              = 1
  desired_capacity      = 1

  # in UTC. +4 hours to EST
  # scale up at 0700 EST every weekday
  recurrence = "0 11 * * 1-5"

  autoscaling_group_name = "${aws_autoscaling_group.this.name}"
}

resource "aws_elb" "this" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  name            = "malicious-elb"
  security_groups = ["${var.elb_sg}"]
  subnets         = "${var.subnet_ids}"

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    target              = "HTTP:80/index.html"
    interval            = 10
    timeout             = 5
  }
}

resource "aws_autoscaling_attachment" "this" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  autoscaling_group_name = "${aws_autoscaling_group.this.id}"
  elb                    = "${aws_elb.this.id}"
}
