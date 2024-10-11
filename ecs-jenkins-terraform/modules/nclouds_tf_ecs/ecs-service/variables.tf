variable "identifier" {
  description = "The name for the cluster"
  type        = string
}

variable "vpc_id" {
  description = "Id of vpc"
  type        = string
}

variable "target_type" {
  description = "The type of target that you must specify when registering targets with this target group"
  default     = "ip"
  type        = string
}

variable "capacity_provider_name" {
  description = "The capacity provider to use for service's tasks"
  default     = "FARGATE"
  type        = string
}

variable "health_check_path" {
  description = "The destination for the health check request"
  default     = "/"
  type        = string
}

variable "path_pattern" {
  description = "Path pattern to match against the request URL"
  default     = ["/*"]
  type        = list(string)
}


variable "cluster" {
  description = "ARN of an ECS cluster"
  type = string
}

variable "task_definition" {
  description = "The family and revision (family:revision) or full ARN of the task definition that you want to run in your service"
  type        = string
}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  default     = 2
  type        = number
}

variable "scheduling_strategy" {
  description = "The scheduling strategy to use for the service. The valid values are REPLICA and DAEMON"
  default     = "REPLICA"
  type        = string
}

variable "deployment_maximum_percent" {
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment"
  default     = 200
  type        = number
}

variable "deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
  default     = 50
  type        = number
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map(any)
}

variable "target_protocol" {
  description = "Protocol for target group"
  type        = string
  default     = "HTTP"
}

variable "stickiness_enabled" {
  type        = bool
  default     = true
  description = "stickiness for targetgroup"
}


variable "max_task_capacity" {
  type        = string
  description = "maximum capacity for ecs service tasks"
}

variable "min_task_capacity" {
  type        = string
  description = "minimum capacity for ecs service tasks"
}

variable "scale_threshold" {
  type        = string
  description = "scaling threshold for ecs service tasks (cpu & memory)"
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks"
  default     = "SERVICE"
  type        = string
}

variable "health_http_check_port" {
  type = number
  default = null
  description = "http port for health check"
}
variable "container_port" {
  description = "The port that the container service runs on"
  type        = number
}

variable "port_mappings" {
  description = "The port mappings to configure for the container"
  default = [
    {
      containerPort = 8080
    }
  ]
  type = list(object({
    containerPort = number
  }))
}

variable "alb_listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}
variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "platform_version" {
  description = "platform version for fargate"
  type        = string
}

variable "services" {
  description = "List of services to deploy"
  default     = {}
  type = map(object({
    capacity_provider_name = string,
    version                = optional(string)
    protocol               = string,
    memory                 = number,
    cpu                    = number,
    desired                = number,
    min                    = number,
    max                    = number,
    min_task_capacity      = number,
    max_task_capacity      = number,
    scale_threshold        = number,
    health_check           = string,
    health_check_port      = optional(number),
    iam_policies           = list(string),
    port_mappings = list(object({
      containerPort = number,
      hostPort      = number,
      protocol      = string
    })),
    environment = map(string),
    secrets = list(object({
      name      = string,
      valueFrom = string
    }))
  }))
}

variable jenkins_jnlp_port {
  type    = number
  default = 50000
}