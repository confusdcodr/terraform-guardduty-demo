## Overview
Creates a malicious instnace for guardduty testing purposes. This following resources are created:
* SSH Keypair
* IAM Role
* IAM Policy to attach to the IAM Role. The policy allows for GuardDuty:List* and EC2:Describe*
* EC2 Instance with UserData script. The script will make a few AWS API calls to get information about the App Server and then attempt to SSH into it
