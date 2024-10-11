locals {
  default_tags = {
    Environment = terraform.workspace
  }
  tags = merge(local.default_tags, var.tags)
}

resource "aws_alb" "main" {
  name            = "${var.identifier}-${terraform.workspace}-alb"
  subnets         = var.subnet_ids
  security_groups = [var.lb_security_group_id]
  tags            = local.tags
}

resource "aws_alb_target_group" "app" {
  name        = "${var.identifier}-${terraform.workspace}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = local.tags

  health_check {
    healthy_threshold   = "3"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "59"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

# Redirect all http traffic from the ALB to the target group
resource "aws_alb_listener" "alb_http" {
  load_balancer_arn = aws_alb.main.id
  port              = var.jenkins_controller_port
  protocol          = "HTTP"
  tags              = local.tags

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ALB listner for Secure Traffic
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.main.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app.arn
  }
}

# Rule for ALB to redirect http to https
resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn =  aws_alb_listener.alb_http.arn

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    http_header {
      http_header_name = "*"
      values           = ["*"]
    }
  }
}