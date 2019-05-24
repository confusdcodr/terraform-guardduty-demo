variable "tags" {
  description = "Map of tags to apply to resources"
  default     = {}
}

variable "create_malicious_instance" {
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
  description = "target security group for the compromised instance"
  default     = ""
}

variable "project_name" {
  type = "string"
}

variable "permissions_boundary_arn" {
  type        = "string"
  description = "ARN of the permissions boundary"
}

variable "target_sg" {
  type        = "string"
  description = "Target security group for the instance"
  default     = ""
}

variable "guarddty_obj_location" {
  type        = "string"
  description = "Guardduty threat list bucket"
  default     = ""
}

variable "guardduty_ip_list_object" {
  type        = "string"
  description = "Guardduty threat list object name"
  default     = "MyThreatIntelSet"
}
