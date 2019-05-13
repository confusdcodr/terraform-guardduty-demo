#         "SecurityGroupIds": [
#             {
#                 "Fn::GetAtt": [
#                     "TestSecurityGroup",
#                     "GroupId"
#                 ]
#             }
#         ],
#         "SubnetId": {
#             "Ref": "TestSubnet"
#         },
#         "Tags": [
#             {
#                 "Key": "Type",
#                 "Value": "App Server"
#             },
#             {
#                 "Key": "Name",
#                 "Value": "App Server"
#             }
#         ],
#         "UserData": {
#             "Fn::Base64": {
#                 "Fn::Join": [
#                     "",
#                     [
#                         "#!/bin/bash\n",
#                         "while [ $(aws guardduty list-detectors --region us-west-2 --output table | wc -l) -le 3 ]; do  echo waiting; sleep 1; done\n",
#                         "while [ $(aws ec2 describe-instances --region us-west-2 --filters \"Name=tag:Type,Values='Malicious Instance'\" \"Name=instance-state-name,Values=running\" --query 'Reservations[0].Instances[0].PublicIpAddress' | tr -d \\\") == \"null\" ]; do sleep 1; done\n",
#                         "TARGET_IP=$(aws ec2 describe-instances --region us-west-2 --filters \"Name=tag:Type,Values='Malicious Instance'\" \"Name=instance-state-name,Values=running\" --query 'Reservations[0].Instances[0].PublicIpAddress' | tr -d \\\")\n",
#                         "while true; do curl $TARGET_IP; sleep 15; done\n"
#                     ]
#                 ]
#             }
#         }
#     }
# },
# "TestEc2InstanceRole": {
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
#                 "PolicyName": "test-instance-policy",
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
#         "RoleName": "test-instance-role"
#     }
# },
# "TestInstanceProfile": {
#     "Type": "AWS::IAM::InstanceProfile",
#     "Properties": {
#         "Path": "/",
#         "Roles": [
#             {
#                 "Ref": "TestEc2InstanceRole"
#             }
#         ]
#     }
# }
