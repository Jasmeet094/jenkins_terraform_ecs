variable "identifier" {
  description = "Identifier for naming resources"
  type        = string
}

variable "execution_role_arn" {
  description = "The Amazon Resource Name (ARN) of the task execution role that the Amazon ECS container agent and the Docker daemon can assume"
  default     = null
  type        = string
}

variable "fargate_cpu" {
  description = "CPU units for Fargate task"
  type        = number
}

variable "fargate_memory" {
  description = "Memory units for Fargate task"
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

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

variable "secrets" {
  description = "The secrets to pass to the container. This is a list of maps"
  default     = []
  type = list(object(
    {
      name      = string
      valueFrom = string
    }
  ))
}

variable "scheduling_strategy" {
  description = "The scheduling strategy to use for the service. The valid values are REPLICA and DAEMON"
  default     = "REPLICA"
  type        = string
}

variable "requires_compatibilities" {
  description = "Enabled compatibilities for task"
  default     = "FARGATE"
  type        = string
}

variable "network_mode" {
  description = "the task definition network mode"
  default     = "awsvpc"
  type        = string
}

variable "container_memory_reservation" {
  description = "The amount of memory (in MiB) to reserve for the container. "
  default     = 128
  type        = number
}

variable "container_image" {
  type = string
}

variable "region" {
  type = string
  default = ""
}

variable "log_configuration" {
  description = "The log configuration for the container"
  default = {
    logDriver = "awslogs",
    options = {
      "awslogs-group"        = "/ecs/jenkins-app"
      "awslogs-region"       = "us-east-1"  
      "awslogs-stream-prefix"= "ecs"
    }
  }
  type = object({
    logDriver = string
    options   = map(string)
  })
}

variable "file_system_id" {
  description = "The ID of the EFS file system"
  type        = string
}

variable "aws_account_id" {
  description = "The ID of the AWS Account"
  type        = string
}


variable "mount_points" {
  description = "Container mount points. This is a list of maps, where each map should contain a `containerPath` and `sourceVolume`"
  default     = []
  type = list(object(
    {
      containerPath = string
      sourceVolume  = string
    }
  ))
}

variable jenkins_controller_port {
  type    = number
  default = 8080
}


variable jenkins_jnlp_port {
  type    = number
  default = 50000
}


variable "cloudwatch_log_group" {
  description = "The name of cloudwach log group"
  type = string
}

variable "task_role_arn" {
  description = "The ARN of the IAM role that containers in this task can assume"
  type        = string
}

variable "efs_access_point_id" {
  description = "The ID of the EFS access point"
  type        = string
}
