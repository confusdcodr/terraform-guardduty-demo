variable "project_name" {
  type    = "string"
  default = "guardduty-demo"
}

variable "create_vpc_flow_logs" {
  type    = "string"
  default = true
}

variable "vpc_id" {
  type = "string"
}
