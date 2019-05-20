variable "create_app_server" {
  description = "boolean that controls the creation of the malicious instance"
  default     = false
}

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

variable "instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "private_ip" {
  type        = "string"
  description = "Private IP address to associate with the instance"
  default     = ""
}

variable "security_group_id" {
  type        = "string"
  description = "target security group for the app server instance"
  default     = ""
}

variable "resource_name" {
  type = "string"
}
