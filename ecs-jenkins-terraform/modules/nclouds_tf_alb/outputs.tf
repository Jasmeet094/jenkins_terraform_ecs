output "alb_id" {
  value = aws_alb.main.id
}

output "target_group_arn" {
  value = aws_alb_target_group.app.arn
}

output "alb_http_listener_arn" {
  value = aws_alb_listener.alb_http.arn
}

output "alb_https_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "alb_dns_name" {
  value = aws_alb.main.dns_name
}

output "alb_zone_id" {
  value = aws_alb.main.zone_id
}