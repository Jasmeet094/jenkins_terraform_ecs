resource "aws_ecs_cluster" "main" {
  name = "${var.identifier}-${terraform.workspace}-master-cluster"
  tags = var.tags
}

resource "aws_ecs_cluster" "jenkins_worker" {
  name = "${var.identifier}-${terraform.workspace}-worker-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}