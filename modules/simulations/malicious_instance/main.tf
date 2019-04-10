####################################
# Key Pair
####################################

locals {
  key_pair_specified      = "${var.key_pair_name == ""}"
  key_pair_write          = "${local.key_pair_specified && var.write_private_key}"
  generated_key_pair_name = "${var.resource_name}-gitlab-runner"
  key_pair_name           = "${ local.key_pair_specified ? local.generated_key_pair_name : var.key_pair_name }"
  key_pair_path           = "${path.module}/generated}"

  tags = {
    Description = "Malicious"
  }
}

resource "tls_private_key" "this" {
  count = "${local.key_pair_specified ? 1 : 0}"

  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "this" {
  count = "${local.key_pair_specified ? 1 : 0}"

  key_name   = "${local.generated_key_pair_name}"
  public_key = "${tls_private_key.this.public_key_openssh}"
}

resource "local_file" "private_key" {
  count = "${local.key_pair_write ? 1 : 0}"

  content  = "${tls_private_key.this.private_key_pem}"
  filename = "${path.module}/${var.resource_name}.pem"
}

resource "null_resource" "chmod_key" {
  count = "${local.key_pair_write ? 1 : 0}"

  depends_on = ["local_file.private_key"]

  provisioner "local-exec" {
    command = "chmod 600 ${local.key_pair_path}/${local.generated_key_pair_name}.pem"
  }
}

data "aws_region" "current" {}

# create the instance profile

data "template_file" "policy" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  template = "${file("iam/policy.json")}"
}

data "aws_iam_policy_document" "policy" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  source_json = "${data.template_file.policy.rendered}"
}

data "template_file" "trust" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  template = "${file("iam/trust.json")}"
}

data "aws_iam_policy_document" "trust" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  source_json = "${data.template_file.trust.rendered}"
}

resource "aws_iam_role" "this" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  name                  = "MaliciousInstanceRole"
  description           = "Role attached to the Malicious instance profile"
  assume_role_policy    = "${data.aws_iam_policy_document.trust.json}"
  force_detach_policies = true
  max_session_duration  = "43200"
  tags                  = "${local.tags}"
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

# format the instance userdata

data "template_file" "userdata" {
  template = "${file("user_data.tpl")}"

  vars = {
    target_region = "${data.aws_region.current.name}"
  }
}

# create the instance

resource "aws_instance" "compromised" {
  count = "${var.create_malicious_instance ? 1 : 0 }"

  ami                  = "${data.aws_ami.amazon_linux.id}"
  instance_type        = "${var.instance_type}"
  private_ip           = "${var.private_ip}"
  user_data            = "${data.template_file.userdata.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.this.name}"
}

# "MaliciousInstance": {
#     "Type": "AWS::EC2::Instance",
#     "Properties": {
#         "IamInstanceProfile": {
#             "Ref": "MaliciousInstanceProfile"
#         },
#         "ImageId": "ami-07eb707f",
#         "InstanceType": "t2.micro",
#         "KeyName": {
#             "Ref": "AWS::AccountId"
#         },
#         "PrivateIpAddress": {
#             "Fn::FindInMap": [
#                 "InstanceConfig",
#                 "MaliciousInstance",
#                 "Ip"
#             ]
#         },
#         "SecurityGroupIds": [
#             {
#                 "Fn::GetAtt": [
#                     "MaliciousSecurityGroup",
#                     "GroupId"
#                 ]
#             }
#         ],
#         "SubnetId": {
#             "Ref": "MaliciousSubnet"
#         },
#         "Tags": [
#             {
#                 "Key": "Type",
#                 "Value": "Malicious Instance"
#             },
#             {
#                 "Key": "Name",
#                 "Value": "Malicious Instance"
#             }
#         ],
#         "UserData": {
#             "Fn::Base64": {
#                 "Fn::Join": [
#                     "",
#                     [
#                         "#!/bin/bash\n",
#                         "while [ $(aws guardduty list-detectors --region us-west-2 --output table | wc -l) -le 3 ]; do  echo waiting; sleep 1; done\n",
#                         "while [ $(aws ec2 describe-instances --region us-west-2 --filters \"Name=tag:Type,Values='App Server'\" \"Name=instance-state-name,Values=running\" --query 'Reservations[0].Instances[0].PublicIpAddress' | tr -d \\\") == \"null\" ]; do sleep 1; done\n",
#                         "TARGET_IP=$(aws ec2 describe-instances --region us-west-2 --filters \"Name=tag:Type,Values='App Server'\" \"Name=instance-state-name,Values=running\" --query 'Reservations[0].Instances[0].PublicIpAddress' | tr -d \\\")\n",
#                         "while true; do ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no $TARGET_IP; sleep 4; done\n"
#                     ]
#                 ]
#             }
#         }
#     }
# },
# "MaliciousEc2InstanceRole": {
#     "Type": "AWS::IAM::Role",
#     "Properties": {
#         "AssumeRolePolicyDocument": {
#             "Version": "2012-10-17",
#             "Statement": [
#                 {
#                     "Effect": "Allow",
#                     "Principal": {
#                         "Service": [
#                             "ec2.amazonaws.com"
#                         ]
#                     },
#                     "Action": [
#                         "sts:AssumeRole"
#                     ]
#                 }
#             ]
#         },
#         "Path": "/",
#         "Policies": [
#             {
#                 "PolicyName": "malicious-instance-policy",
#                 "PolicyDocument": {
#                     "Version": "2012-10-17",
#                     "Statement": [
#                         {
#                             "Action": [
#                                 "guardduty:List*",
#                                 "ec2:Describe*"
#                             ],
#                             "Effect": "Allow",
#                             "Resource": "*"
#                         }
#                     ]
#                 }
#             }
#         ],
#         "RoleName": "malicious-instance-role"
#     }
# },
# "MaliciousInstanceProfile": {
#     "Type": "AWS::IAM::InstanceProfile",
#     "Properties": {
#         "Path": "/",
#         "Roles": [
#             {
#                 "Ref": "MaliciousEc2InstanceRole"
#             }
#         ]
#     }
# },

