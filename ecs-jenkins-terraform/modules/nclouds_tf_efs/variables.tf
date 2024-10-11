variable "identifier" {
  description = "Name for the resources"
  type        = string
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

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

