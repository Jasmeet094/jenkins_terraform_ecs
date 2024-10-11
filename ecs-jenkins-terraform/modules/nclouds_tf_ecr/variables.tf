variable "identifier" {
  description = "Name for the resources"
  type        = string
}
variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

variable "region" {
  description = "The region in which resources will gets deployed"
  type        = string
}

variable "aws_log_group" {
  description = "The name of clpoudwatch log group"
  type        = string
}

variable "aws_log_stream" {
  description = "The name of cloudwatch log group stream"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of ALB"
  type        = string
}

variable "jenkins_controller_port" {
  description = "Port number for Jenkins controller"
  type        = number
}

variable "jenkins_jnlp_port" {
  description = "Jenkins JNLP port"
  type        = number
}

variable "jenkins_controller_subnet_ids" {
  description = "List of subnet IDs for Jenkins controller"
  type        = list(string)
}

variable "ecs_cluster_master_arn" {
  description = "ARN of the ECS cluster for master"
  type        = string
}

variable "ecs_cluster_worker_arn" {
  description = "ARN of the ECS cluster for worker"
  type        = string
}

variable "ecs_tasks_sg" {
  description = "Security group IDs for Jenkins agents"
  type        = list(string)
}


variable "task_execution_role_arn" {
  description = "execution role arn"
  type        = string
}

variable "task_role_arn" {
  description = "task role arn"
  type        = string
}


variable "platform_version" {
  description = "platform version for fargate"
  type        = string
}

variable "profile" {
  description = "The AWS profile to use for authentication"
  type        = string
  default     = "aws-sandbox"
}

variable "dns_record_name" {
  description = "The DNS record name for Jenkins"
  type        = string
}