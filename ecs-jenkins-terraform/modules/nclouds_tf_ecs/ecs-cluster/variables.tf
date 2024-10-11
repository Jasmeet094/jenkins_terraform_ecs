variable "identifier" {
  description = "Identifier for naming resources"
  type        = string
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}
