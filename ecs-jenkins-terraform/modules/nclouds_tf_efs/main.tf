data "aws_subnet" "private_subnets" {
  for_each = toset(var.vpc_settings.private_subnets)
  filter {
    name   = "cidr-block"
    values = [each.value]
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_efs_file_system" "efs_volume" {
  performance_mode = "generalPurpose"

  creation_token = "jenkins-efs-volume"
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
  tags = {
    Name      = "${var.identifier}-${terraform.workspace}-efs"
    ManagedBy = "terraform"
  }
}

resource "aws_efs_mount_target" "ecs_temp_space" {
  for_each = data.aws_subnet.private_subnets

  file_system_id  = aws_efs_file_system.efs_volume.id
  subnet_id       = each.value.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_access_point" "efs_access" {
  file_system_id = aws_efs_file_system.efs_volume.id

  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
}

resource "aws_security_group" "efs_sg" {
  name   = "${var.identifier}-${terraform.workspace}-efs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
