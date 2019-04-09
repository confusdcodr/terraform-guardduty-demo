####################################
# Key Pair
####################################

locals {
  key_pair_specified      = "${var.key_pair_name == ""}"
  key_pair_write          = "${local.key_pair_specified && var.write_private_key}"
  generated_key_pair_name = "${var.resource_name}-gitlab-runner"
  key_pair_name           = "${ local.key_pair_specified ? local.generated_key_pair_name : var.key_pair_name }"
  key_pair_path           = "${path.module}/generated}"
}

resource "tls_private_key" "this" {
  count     = "${local.key_pair_specified ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "this" {
  count      = "${local.key_pair_specified ? 1 : 0}"
  key_name   = "${local.generated_key_pair_name}"
  public_key = "${tls_private_key.this.public_key_openssh}"
}

resource "local_file" "private_key" {
  count    = "${local.key_pair_write ? 1 : 0}"
  content  = "${tls_private_key.this.private_key_pem}"
  filename = "${path.module}/${var.resource_name}.pem"
}

resource "null_resource" "chmod_key" {
  count      = "${local.key_pair_write ? 1 : 0}"
  depends_on = ["local_file.private_key"]

  provisioner "local-exec" {
    command = "chmod 600 ${local.key_pair_path}/${local.generated_key_pair_name}.pem"
  }
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

