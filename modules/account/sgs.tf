# get the caller's public ip and add it as a local
data "http" "ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_security_group" "default" {
  vpc_id = "${var.vpc_id}"
  name   = "default"
}

locals {
  caller_public_ip = "${chomp(data.http.ip.body)}/32"
}

# linux app server sg
resource "aws_security_group" "linux_app_server" {
  depends_on = ["aws_security_group.malicious_instance"]

  description = "Allow inbound traffic"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "Linux App Server SG"))}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["${var.cidr_block}", "${local.caller_public_ip}"]
    security_groups = ["${aws_security_group.malicious_instance.id}", "${data.aws_security_group.default.id}"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["${var.cidr_block}", "${local.caller_public_ip}"]
    security_groups = ["${aws_security_group.malicious_instance.id}", "${data.aws_security_group.default.id}"]
  }

  ingress {
    from_port       = 5050
    to_port         = 5050
    protocol        = "tcp"
    cidr_blocks     = ["${var.cidr_block}", "${local.caller_public_ip}"]
    security_groups = ["${aws_security_group.malicious_instance.id}", "${data.aws_security_group.default.id}"]
  }

  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    cidr_blocks     = ["${var.cidr_block}", "${local.caller_public_ip}"]
    security_groups = ["${aws_security_group.malicious_instance.id}", "${data.aws_security_group.default.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# windows app server sg
resource "aws_security_group" "windows_app_server" {
  depends_on = ["aws_security_group.malicious_instance"]

  description = "Allow inbound traffic"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "Windows App Server SG"))}"

  ingress {
    from_port       = 3389
    to_port         = 3389
    protocol        = "tcp"
    cidr_blocks     = ["${var.cidr_block}", "${local.caller_public_ip}"]
    security_groups = ["${aws_security_group.malicious_instance.id}", "${data.aws_security_group.default.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# malicious instance sg
resource "aws_security_group" "malicious_instance" {
  description = "Allow inbound traffic"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "Malicious Instance SG"))}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["${var.cidr_block}", "${local.caller_public_ip}"]
    security_groups = ["${data.aws_security_group.default.id}"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["${var.cidr_block}", "${local.caller_public_ip}"]
    security_groups = ["${aws_security_group.malicious_elb.id}", "${data.aws_security_group.default.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# malicious instance elb
resource "aws_security_group" "malicious_elb" {
  description = "Allow inbound traffic"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "Malicious Instance ELB"))}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}", "${local.caller_public_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_block}"]
  }
}
