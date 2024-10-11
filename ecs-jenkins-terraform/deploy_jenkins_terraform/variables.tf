
variable "profile" {
  description = "The AWS profile to use"
  type        = string
  default     = "aws-sandbox"
}

variable "prod_profile" {
  description = "The AWS profile to use for Prod account"
  type        = string
  default     = "aws-production"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  default     = 2
  type        = number
}


variable "aws_service_principal" {
  description = "The service principal allowed to assume this role. Example: 'ec2.amazonaws.com'"
  type        = string
  default     = "ecs.amazonaws.com"
}

variable "identifier" {
  description = "Name for the resources"
  type        = string
}

variable "fargate_platform_version" {
  description = "Fargate Platform Version"
  type        = string
}

variable "ec2_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role name"
  default     = "myEcsAutoScaleRole"
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map(any)
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "log_configuration" {
  description = "The log configuration for the container"
  default = {
    logDriver = "awslogs",
    options = {
      "awslogs-group"         = "/ecs/jenkins-app"
      "awslogs-region"        = "us-east-1" # You can replace this with a variable if you want it to be dynamic
      "awslogs-stream-prefix" = "ecs"
    }
  }
  type = object({
    logDriver = string
    options   = map(string)
  })
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

variable "container_image" {
  description = "Docker image to run in the ECS cluster"
  default     = ""
}

variable "jenkins_controller_port" {
  type    = number
  default = 8080
}

variable "health_check_path" {
  default = "/login"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = 1024
  type        = number
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = 2048
  type        = number
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

variable "container_memory_reservation" {
  description = "The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container_memory hard limit"
  default     = 128
  type        = number
}

variable "services" {
  description = "List of services to deploy"
  type = map(object({
    capacity_provider_name = string,
    version                = optional(string),
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
      containerPort = number
    })),
    environment = map(string),
    secrets = list(object({
      name      = string,
      valueFrom = string
    }))
  }))
}

variable "aws_account_id" {
  description = "The ID of the AWS Account"
  type        = string
}

variable "jenkins_jnlp_port" {
  type    = number
  default = 50000
}
