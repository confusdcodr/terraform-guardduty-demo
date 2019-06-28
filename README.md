# terraform-aws-ir

Terraform AWS Incident Response Sandbox

## Sources

- [amazon-guardduty-tester](https://github.com/awslabs/amazon-guardduty-tester)
- [amazon-guardduty-handson](https://github.com/aws-samples/amazon-guardduty-hands-on)

## Remediation Actions

IAM user

- remove all policies associated with the user (log what they were)
- move user to the `/compromised` path

EC2 instance

- isolate it

## ToDo

- [ ] CI
  - [ ] add linting
  - [ ] auto-generate docs
- [ ] add cloudwatch alarms and sns topics for 'spending guard'
- [ ] add misconfigured s3 bucket generation to a non-malicious instance