variable "project_name" {
  type    = "string"
  default = "guardduty-demo"
}

variable "cidr_block" {
  description = "Private IP CIDR block to assign to the instances"
  default     = "172.31.0.0/16"
}
