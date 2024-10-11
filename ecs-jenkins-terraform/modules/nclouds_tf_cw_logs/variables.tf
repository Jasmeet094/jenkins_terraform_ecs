variable "identifier" {
  description = "Identifier for naming resources"
  type        = string
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}


variable "encrypt_log_group" {
  description = "encryption"
  type        = bool
  default     = false

}

variable "key_rotation" {
  description = "rotation"
  type        = bool
  default     = false

}