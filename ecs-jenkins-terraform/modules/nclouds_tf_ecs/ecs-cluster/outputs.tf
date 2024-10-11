output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "jenkins_worker_cluster_name" {
  value = aws_ecs_cluster.jenkins_worker.name
}

output "jenkins_worker_cluster_arn" {
  value = aws_ecs_cluster.jenkins_worker.arn
}
