data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  default_tags = {
    Environment = terraform.workspace
  }
  tags = merge(local.default_tags, var.tags)
}


# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "jenkins_log_group" {
  retention_in_days = 30
  name_prefix       = "${var.identifier}-${terraform.workspace}-"
  tags              = var.tags
}

resource "aws_cloudwatch_log_stream" "jenkins_log_stream" {
  name           = "${var.identifier}-${terraform.workspace}-log_stream"
  log_group_name = aws_cloudwatch_log_group.jenkins_log_group.name
}

