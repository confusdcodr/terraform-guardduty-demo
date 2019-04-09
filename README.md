# terraform-aws-ir

Terraform AWS Incident Response Sandbox

## Sources

[amazon-guardduty-tester](https://github.com/awslabs/amazon-guardduty-tester)
[amazon-guardduty-handson](https://github.com/aws-samples/amazon-guardduty-hands-on)

## Remediation Actions

IAM user

- remove all policies associated with the user (log what they were)
- move user to the `/compromised` path

EC2 instance

- isolate it

## ToDo

- [ ] convert app server to tf
- [ ] convert malicious instance to tf
- [ ] add configurable functionality to the malicious instance
- [ ] add cloudwatch alarms and sns topics for 'spending guard'