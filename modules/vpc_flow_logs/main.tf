resource "aws_s3_bucket" "this" {
  count         = "${var.create_vpc_flow_logs ? 1 : 0}"
  bucket        = "${var.project_name}-vpc-flow-logs"
  force_destroy = true
}

resource "aws_flow_log" "this" {
  count                = "${var.create_vpc_flow_logs ? 1 : 0}"
  
  traffic_type         = "ALL"
  vpc_id               = "${var.vpc_id}"
  log_destination_type = "s3"
  log_destination      = "${aws_s3_bucket.this.arn}"
}
