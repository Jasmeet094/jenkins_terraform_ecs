variable "identifier" {
  description = "Identifier for naming resources"
  type        = string
}

variable "workspace" {
  description = "Workspace for Terraform"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for the VPC"
  type        = bool
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

variable "vpc_settings" {
  description = "Map of AWS VPC settings"
  default = {
    private_subnets = ["172.20.16.0/22", "172.20.20.0/22"]
    public_subnets  = ["172.20.0.0/22", "172.20.4.0/22"]
    dns_hostnames   = true
    dns_support     = true
    tenancy         = "default"
    cidr            = "172.20.0.0/16"
  }
  type = object({
    private_subnets = list(string)
    public_subnets  = list(string)
    dns_hostnames   = bool,
    dns_support     = bool,
    tenancy         = string,
    cidr            = string
  })
}

variable "endpoint_sg" {
  description = "sescurity group ID of secrets manager endpoint"
  type        = list(string)
}
