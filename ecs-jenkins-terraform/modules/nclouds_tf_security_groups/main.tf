locals {
  default_tags = {
    Environment = terraform.workspace
  }
  tags = merge(local.default_tags, var.tags)
}

# Security Group for ALB
resource "aws_security_group" "lb" {
  name        = "${var.identifier}-${terraform.workspace}-lb-sg"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = var.jenkins_controller_port
    to_port     = var.jenkins_controller_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}

# Security Group For ECS Taks , Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.identifier}-${terraform.workspace}-ecs-sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    self            = true
    from_port       = var.jenkins_controller_port
    to_port         = var.jenkins_controller_port
    security_groups = [aws_security_group.lb.id]
    description     = "Allow traffic from ALB on Jenkins controller port"
  }

  ingress {
    protocol        = "tcp"
    self            = true
    security_groups = [aws_security_group.lb.id]
    from_port       = var.jenkins_jnlp_port
    to_port         = var.jenkins_jnlp_port
    description     = "Allow traffic from ALB on Jenkins JNLP port"
  }

  # Loopback rule to allow all traffic within the security group itself
  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    self        = true
    description = "Allow all loopback traffic"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}

# Security Group for VPC Endpoint for Secret Manager
resource "aws_security_group" "endpoint_sg" {
  description = "endpoint sg security group"
  vpc_id      = var.vpc_id
  name        = "${var.identifier}-${terraform.workspace}-secrets-manager-endpoint-sg"

  ingress {
    cidr_blocks = [var.vpc_settings["cidr"]]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  egress {
    cidr_blocks = [var.vpc_settings["cidr"]]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = local.tags
}