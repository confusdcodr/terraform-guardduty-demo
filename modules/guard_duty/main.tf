resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = "ONE_HOUR"
}

resource "aws_s3_bucket" "this" {
  acl    = "private"
  bucket = "${var.project_name}-ipset"
}

resource "aws_s3_bucket_object" "this" {
  acl     = "public-read"
  content = "10.0.0.0/8\n"
  bucket  = "${aws_s3_bucket.this.id}"
  key     = "MyIPSet"
}

resource "aws_guardduty_ipset" "this" {
  activate    = true
  detector_id = "${aws_guardduty_detector.master.id}"
  format      = "TXT"
  location    = "https://s3.amazonaws.com/${aws_s3_bucket_object.this.bucket}/${aws_s3_bucket_object.this.key}"
  name        = "MyIPSet"
}
