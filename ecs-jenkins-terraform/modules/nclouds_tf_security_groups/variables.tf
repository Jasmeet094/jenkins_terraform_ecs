variable "identifier" {
  description = "Identifier for naming resources"
  type        = string
}

variable "workspace" {
  description = "Workspace for Terraform"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "jenkins_controller_port" {
  type    = number
  default = 8080
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

variable "jenkins_jnlp_port" {
  type    = number
  default = 50000
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