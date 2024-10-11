output "efs_volume_id" {
  value = aws_efs_file_system.efs_volume.id
}

output "efs_security_group_id" {
  description = "The security group ID of the EFS security group"
  value       = aws_security_group.efs_sg.id
}

output "efs_volume_arn" {
  value = aws_efs_file_system.efs_volume.arn
}

output "efs_access_point_id" {
  value = aws_efs_access_point.efs_access.id
}