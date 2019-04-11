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

variable "environment" {
  type        = "string"
  description = "Resource name prefix"
  default     = ""
}

variable "create_malicious_user" {
  type    = "string"
  default = "false"
}

variable "create_malicious_instance" {
  type    = "string"
  default = "false"
}
