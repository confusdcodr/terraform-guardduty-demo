variable "db_attributes" {
  type        = "list"
  default     = []
  description = "Schema list of .."
}

variable "tags" {
  type        = "map"
  description = "Map of tags"
  default     = {}
}

variable "table_name" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "project_name" {
  type    = "string"
  default = "guardduty-demo"
}

variable "permissions_boundary_arn" {
  type        = "string"
  description = "ARN of the permissions boundary to associate with the Malicious instance"
}

variable "create_exceptions_table" {
  description = "Controls the creation of the exception table"
  default     = false
}

variable "create_malicious_iam_user" {
  description = "Controls the creation of the malicious IAM user"
  default     = false
}

variable "create_malicious_instance" {
  default = true
}

variable "create_app_server_windows" {
  default = true
}

variable "create_app_server_linux" {
  default = true
}

variable "create_cloudtrail" {
  default = false
}

variable "create_vpc_flow_logs" {
  default = false
}

variable "vpc_id" {
  description = "Target vpc for all instances"
  type        = "string"
  default     = ""
}

variable "key_pair_name" {
  description = "Optional. if defined all instances will be associated with this key"
  type        = "string"
  default     = ""
}

variable "cidr_block" {
  description = "Private IP CIDR block to assign to the instances"
  default     = "172.31.0.0/16"
}
