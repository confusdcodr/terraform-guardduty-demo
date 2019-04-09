variable "create_exceptions_table" {
  type        = "string"
  default     = true
  description = "boolean used to control the creation of the Exceptions Table"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Map of tags to apply to the table"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Schema list of.."
}

variable "table_name" {
  type        = "string"
  description = "Name of the table"
}
