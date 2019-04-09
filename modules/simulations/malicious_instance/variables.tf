variable "key_pair_name" {
  description = "Name of the key pair to use to auth to the runner instance. Leave unspecified to auto create. Use in combination with the write_private_key var to save the key."
  type        = "string"
  default     = ""
}

variable "write_private_key" {
  description = "Boolean to control saving of the generated private ssh key to disk."
  default     = false
}

variable "environment" {
  description = "A name that identifies the environment, will used as a name prefix and for tagging."
  default     = ""
  type        = "string"
}
