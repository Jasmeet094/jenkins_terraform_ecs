variable "identifier" {
  description = "Identifier for naming resources"
  type        = string
}

variable "workspace" {
  description = "Workspace for Terraform"
  type        = string
}

variable "lb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group ID for the ECS tasks"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "health_check_path" {
  description = "Path for ALB health check"
  type        = string
}


variable "certificate_arn" {
  description = "Certificate ARN from Prod account"
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
