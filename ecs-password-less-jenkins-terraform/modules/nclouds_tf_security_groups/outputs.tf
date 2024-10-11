
output "lb_security_group_id" {
  value = aws_security_group.lb.id
}

output "ecs_tasks_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}


output "secrets_ep_security_group_id" {
  value = aws_security_group.endpoint_sg.id
}