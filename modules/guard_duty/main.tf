resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}

resource "aws_s3_bucket" "this" {
  acl    = "private"
  bucket = "GuardDutyDemo-ipset"
}

resource "aws_s3_bucket_object" "this" {
  acl     = "public-read"
  content = "test"

  # content = "${aws_instance.compromised.public_ip}\n${aws_instance.compromised.private_ip}\n"
  bucket = "${aws_s3_bucket.this.id}"
  key    = "MyThreatIntelSet"
}

resource "aws_guardduty_threatintelset" "this" {
  activate    = true
  detector_id = "${aws_guardduty_detector.this.id}"
  format      = "TXT"
  location    = "https://s3.amazonaws.com/${aws_s3_bucket_object.this.bucket}/${aws_s3_bucket_object.this.key}"
  name        = "MyThreatIntelSet"
}
