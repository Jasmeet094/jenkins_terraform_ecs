
output "cluster_name" {
  value = aws_ecs_service.jenkins_controller.cluster
}

output "service_name" {
  value = aws_ecs_service.jenkins_controller.name
}