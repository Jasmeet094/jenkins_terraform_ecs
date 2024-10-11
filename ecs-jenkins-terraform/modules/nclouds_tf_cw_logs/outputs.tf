output "log_group_name" {
  value = aws_cloudwatch_log_group.jenkins_log_group.name
}

output "log_stream_name" {
  value = aws_cloudwatch_log_stream.jenkins_log_stream.name
}
