data "aws_ecr_authorization_token" "token" {}

locals {
  ecr_endpoint = split("/", aws_ecr_repository.jenkins_controller.repository_url)[0]
}

resource "aws_ecr_repository" "jenkins_controller" {
  name                 = "${var.identifier}-${terraform.workspace}-image"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

locals {
  jenkins_configuration_def = templatefile("${path.module}/docker/files/jenkins.yaml.tftpl", {
    ecs_cluster_master       = var.ecs_cluster_master_arn
    ecs_cluster_worker       = var.ecs_cluster_worker_arn
    cluster_region           = var.region
    alb_dns_name             = var.alb_dns_name
    jenkins_controller_port  = tostring(var.jenkins_controller_port),
    jnlp_port                = tostring(var.jenkins_jnlp_port),
    agent_security_groups    = join(",", var.ecs_tasks_sg),
    execution_role_arn       = var.task_execution_role_arn
    task_role_arn            = var.task_role_arn
    subnets                  = join(",", var.jenkins_controller_subnet_ids)
    fargate_platform_version = var.platform_version
    aws_log_group            = var.aws_log_group
    aws_log_stream           = var.aws_log_stream
    dns_record_name          = var.dns_record_name
  })
}

# Null Resource to create JCASC yaml file
resource "null_resource" "render_template" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
tee ${path.module}/docker/files/jenkins.yaml <<ENDF
${local.jenkins_configuration_def}
ENDF
EOF
  }
}

# Create Docker Image & push to ECR 
resource "null_resource" "build_docker_image" {
  triggers = {
    src_hash   = file("${path.module}/docker/files/jenkins.yaml.tftpl")
    always_run = timestamp()
  }

  depends_on = [null_resource.render_template]

  provisioner "local-exec" {
    command = <<EOF
aws ecr get-login-password --region ${var.region} --profile ${var.profile} | docker login --username AWS --password-stdin ${local.ecr_endpoint} && \
docker build --platform linux/amd64 -t ${aws_ecr_repository.jenkins_controller.repository_url}:latest ${path.module}/docker/ && \
docker push ${aws_ecr_repository.jenkins_controller.repository_url}:latest
EOF
  }
}
