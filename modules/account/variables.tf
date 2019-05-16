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

variable "resource_name" {
  type = "string"
}

variable "table_name" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "project_name" {
  type = "string"
  default = "guardduty-demo"
}
