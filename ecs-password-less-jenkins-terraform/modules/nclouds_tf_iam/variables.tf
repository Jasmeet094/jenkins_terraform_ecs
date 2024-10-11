variable "identifier" {
  description = "Identifier for naming resources"
  type        = string
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

variable "aws_service_principal" {
  description = "The service principal allowed to assume this role. Example: 'ec2.amazonaws.com'"
  type        = string
}

variable "iam_policies_to_attach" {
  description = "List of ARNs of IAM policies to attach"
  default     = []
  type        = list(string)
}

variable "ecs_cluster_arns" {
  description = "The ARNs of the ECS clusters"
  type        = list(string)
}


variable "aws_account_id" {
  description = "The AWS Account ID"
  type        = string
}

variable "efs_arn" {
  description = "The ARN of the EFS file system"
  type        = string
}

variable "region" {
  type = string
}