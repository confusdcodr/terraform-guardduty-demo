# bucket to store cloudtrail logs in
resource "aws_s3_bucket" "this" {
  count         = "${var.create_cloudtrail ? 1 : 0}"
  bucket        = "${var.project_name}-cloudtrail"
  force_destroy = true
  policy        = "${data.template_file.this.rendered}"
}

resource "aws_cloudtrail" "this" {
  count = "${var.create_cloudtrail ? 1 : 0}"

  name                          = "${var.project_name}-trail"
  s3_bucket_name                = "${aws_s3_bucket.this.id}"
  include_global_service_events = true
  is_multi_region_trail         = true
}

data "template_file" "this" {
  template = "${file("modules/cloudtrail/policy.json")}"

  vars = {
    s3_bucket = "${var.project_name}-cloudtrail"
  }
}
