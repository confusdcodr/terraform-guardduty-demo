resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}

#resource "aws_s3_bucket" "this" {
#  acl    = "private"
#  bucket = "${var.project_name}-ipset"
#}
#
#resource "aws_s3_bucket_object" "this" {
#  acl     = "public-read"
#  content = "10.0.0.0/8\n"
#  bucket  = "${aws_s3_bucket.this.id}"
#  key     = "MyThreatIntelSet"
#}
#
#resource "aws_guardduty_threatintelset" "this" {
#  activate    = true
#  detector_id = "${aws_guardduty_detector.this.id}"
#  format      = "TXT"
#  location    = "https://s3.amazonaws.com/${aws_s3_bucket_object.this.bucket}/${aws_s3_bucket_object.this.key}"
#  name        = "MyThreatIntelSet"
#}

