variable "tags" {
  description = "Map of tags to apply to resources"
  default     = {}
}

variable "create_app_server_windows" {
  description = "boolean that controls the creation of the malicious instance"
  default     = false
}

variable "instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "private_ip" {
  type        = "string"
  description = "Private IP address to associate with the instance"
  default     = ""
}

variable "vpc_id" {
  type = "string"
}

variable "cidr_block" {
  type = "string"
}

variable "permissions_boundary_arn" {
  type        = "string"
  description = "ARN of the permissions boundary"
}
