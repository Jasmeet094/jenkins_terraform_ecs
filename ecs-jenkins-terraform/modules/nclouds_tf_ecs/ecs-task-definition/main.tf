locals {
  default_tags  = {
    Environment = terraform.workspace
  }
  tags = merge(local.default_tags, var.tags)

  jenkins_controller_container_def = templatefile("${path.module}/../../templates/jenkins-controller.json.tftpl", {
    name                    = "${var.identifier}-${terraform.workspace}-controller"
    jenkins_controller_port = var.jenkins_controller_port
    jnlp_port               = var.jenkins_jnlp_port
    source_volume           = "${var.identifier}-${terraform.workspace}-efs"
    jenkins_home            = "/var/jenkins_home"
    container_image         = var.container_image
    region                  = var.region
    account_id              = var.aws_account_id
    log_group               = var.cloudwatch_log_group
    memory                  = var.fargate_memory
    cpu                     = var.fargate_cpu
    secrets                 = jsonencode(var.secrets)
  })
}

resource "aws_ecs_task_definition" "jenkins_controller" {
  family                   = "${var.identifier}-${terraform.workspace}-ta"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  network_mode             = var.network_mode
  requires_compatibilities = [var.requires_compatibilities]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = local.jenkins_controller_container_def

  volume {
    name = "${var.identifier}-${terraform.workspace}-efs"
    efs_volume_configuration {
      file_system_id = var.file_system_id
      root_directory = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_id
      }
    }
    
  }

  tags = var.tags
}



