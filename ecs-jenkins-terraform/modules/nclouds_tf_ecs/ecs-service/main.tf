locals {
  default_tags = {
    Environment = terraform.workspace
  }
  tags                   = merge(local.default_tags, var.tags)
  container_port = var.port_mappings[0].containerPort

}

data "aws_ecs_task_definition" "latest" {
  task_definition = join(":", slice(split(":", var.task_definition), 0, 6))
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_ecs_service" "jenkins_controller" {

  scheduling_strategy = var.scheduling_strategy
  task_definition     =  var.task_definition
  propagate_tags      = var.propagate_tags
  desired_count       = var.desired_count
  cluster             = var.cluster
  name                = "${var.identifier}-${terraform.workspace}-controller-svc"
  platform_version    = var.platform_version
  network_configuration {
    security_groups  = var.security_groups
    subnets          = var.subnets
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.controller.arn
    port =  var.jenkins_jnlp_port
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   =  "${var.identifier}-${terraform.workspace}-controller"
    container_port   =   local.container_port
  }

  depends_on = [
    var.alb_listener_arn
  ]

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 5
  }
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

}

resource "aws_service_discovery_private_dns_namespace" "controller" {
  name = "${var.identifier}-${terraform.workspace}-dns-ns"
  vpc = var.vpc_id
  description = "Serverless Jenkins discovery managed zone."
}


resource "aws_service_discovery_service" "controller" {
  name = "controller"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.controller.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl = 10
      type = "A"
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }
  }
  health_check_custom_config {
    failure_threshold = 5
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  service_namespace  = "ecs"
  resource_id        = "service/jenkins-${terraform.workspace}-master-cluster/${aws_ecs_service.jenkins_controller.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_task_capacity
  max_capacity       = var.max_task_capacity
  tags               = var.tags

}

resource "aws_appautoscaling_policy" "cpu_scale_up" {
  name               = "asg_scaleup_tasks_cpu"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}

resource "aws_appautoscaling_policy" "cpu_scale_down" {
  name               = "asg_scaledown_tasks_cpu"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}

resource "aws_appautoscaling_policy" "ecs_policy_up_memory" {
  name               = "scaleup-tasks-memory"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_down_memory" {
  name               = "scaledown-tasks-memory"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_scaleup" {
  alarm_name          = "scaleup-cpu-${aws_ecs_service.jenkins_controller.name}-${terraform.workspace}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.scale_threshold
  alarm_description   = "CPU Alarm to trigger when cpu is greater or equal 80%"
  actions_enabled     = "true"
  alarm_actions       = [aws_appautoscaling_policy.cpu_scale_up.arn]

  dimensions = {
    ClusterName = "jenkins-${terraform.workspace}-master-cluster"
    ServiceName = aws_ecs_service.jenkins_controller.name
  }

}

resource "aws_cloudwatch_metric_alarm" "service_cpu_scaledown" {
  alarm_name          = "scaledown-cpu-${aws_ecs_service.jenkins_controller.name}-${terraform.workspace}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.scale_threshold
  alarm_description   = "CPU Alarm to trigger when cpu is less than 80%"
  actions_enabled     = "true"
  alarm_actions       = [aws_appautoscaling_policy.cpu_scale_down.arn]

  dimensions = {
    ClusterName = "jenkins-${terraform.workspace}-master-cluster"
    ServiceName = aws_ecs_service.jenkins_controller.name
  }

}

resource "aws_cloudwatch_metric_alarm" "service_memory_scaleup" {
  alarm_name          = "scaleup-memory-${aws_ecs_service.jenkins_controller.name}-${terraform.workspace}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.scale_threshold
  alarm_description   = "Memory Alarm to trigger when memory is greater or equal 80%"
  actions_enabled     = "true"
  alarm_actions       = [aws_appautoscaling_policy.ecs_policy_up_memory.arn]

  dimensions = {
    ClusterName = "jenkins-${terraform.workspace}-master-cluster"
    ServiceName = aws_ecs_service.jenkins_controller.name
  }

}

resource "aws_cloudwatch_metric_alarm" "service_memory_scaledown" {
  alarm_name          = "scaledown-memory-${aws_ecs_service.jenkins_controller.name}-${terraform.workspace}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.scale_threshold
  alarm_description   = "Memory Alarm to trigger when memory is less than 80%"
  actions_enabled     = "true"
  alarm_actions       = [aws_appautoscaling_policy.ecs_policy_down_memory.arn]

  dimensions = {
    ClusterName = "jenkins-${terraform.workspace}-master-cluster"
    ServiceName = aws_ecs_service.jenkins_controller.name
  }

}
