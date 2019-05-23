variable "create_malicious_user" {
  type    = "string"
  default = "false"
}

variable "project_name" {
  type = "string"
}

variable "tags" {
  description = "Map of tags to apply to resources"
  default     = {}
}
