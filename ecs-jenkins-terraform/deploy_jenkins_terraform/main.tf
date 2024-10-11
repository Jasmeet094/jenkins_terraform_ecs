
data "aws_route53_zone" "selected" {
  name     = "tronixtrm.com"

}

data "aws_acm_certificate" "issued" {
  domain   = "*.TEST_CERT.com"
  statuses = ["ISSUED"]
}

module "ecs_cluster" {
  source     = "../modules/nclouds_tf_ecs/ecs-cluster"
  identifier = var.identifier
  tags       = var.tags
}

module "service" {
  source                 = "../modules/nclouds_tf_ecs/ecs-service"
  vpc_id                 = module.network.vpc_id
  alb_listener_arn       = module.alb.alb_https_listener_arn
  target_group_arn       = module.alb.target_group_arn
  health_http_check_port = var.services.jenkins.health_check_port
  health_check_path      = var.services.jenkins.health_check
  security_groups        = [module.security.ecs_tasks_security_group_id]
  identifier             = "jenkins"
  task_definition        = module.jenkins_controller_task.task_definition_arn
  container_port         = var.services.jenkins.port_mappings[0].containerPort
  desired_count          = var.services.jenkins.desired
  cluster                = module.ecs_cluster.cluster_name
  subnets                = module.network.private_subnet_ids
  scale_threshold        = var.services.jenkins.scale_threshold
  min_task_capacity      = var.services.jenkins.min_task_capacity
  max_task_capacity      = var.services.jenkins.max_task_capacity
  tags                   = merge(var.tags, { service_name = "jenkins" })
  platform_version       = var.fargate_platform_version
  depends_on             = [module.jenkins_controller_task]

}

module "jenkins_controller_task" {
  source                       = "../modules/nclouds_tf_ecs/ecs-task-definition"
  identifier                   = var.identifier
  execution_role_arn           = module.task_role_worker.ecs_task_execution_role_arn
  task_role_arn                = module.task_role_worker.ecs_task_role_arn
  fargate_cpu                  = var.services.jenkins.cpu
  fargate_memory               = var.services.jenkins.memory
  container_image              = module.ecr.repository_url
  container_memory_reservation = var.services.jenkins.memory
  file_system_id               = module.efs.efs_volume_id
  secrets                      = var.services.jenkins.secrets
  cloudwatch_log_group         = module.log_group_worker.log_group_name
  region                       = var.aws_region
  aws_account_id               = var.aws_account_id
  tags                         = var.tags
  efs_access_point_id          = module.efs.efs_access_point_id
  depends_on                   = [module.ecr]
}

module "task_role_worker" {
  source = "../modules/nclouds_tf_iam"
  iam_policies_to_attach = concat([
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
  ], var.services.jenkins.iam_policies)
  aws_service_principal = "ecs-tasks.amazonaws.com"
  ecs_cluster_arns      = [module.ecs_cluster.cluster_arn, module.ecs_cluster.jenkins_worker_cluster_arn]
  efs_arn               = module.efs.efs_volume_arn
  identifier            = "${var.identifier}-jenkins-task"
  aws_account_id        = var.aws_account_id
  region                = var.aws_region
  tags                  = var.tags
}

module "log_group_worker" {
  source     = "../modules/nclouds_tf_cw_logs"
  identifier = "${var.identifier}-log-grp"
  tags       = var.tags
}

module "ecr" {
  source                        = "../modules/nclouds_tf_ecr"
  identifier                    = var.identifier
  region                        = var.aws_region
  jenkins_controller_port       = var.jenkins_controller_port
  jenkins_jnlp_port             = var.jenkins_jnlp_port
  jenkins_controller_subnet_ids = module.network.private_subnet_ids
  tags                          = var.tags
  ecs_cluster_master_arn        = module.ecs_cluster.cluster_arn
  ecs_cluster_worker_arn        = module.ecs_cluster.jenkins_worker_cluster_arn
  ecs_tasks_sg                  = [module.security.ecs_tasks_security_group_id]
  task_execution_role_arn       = module.task_role_worker.ecs_task_execution_role_arn
  task_role_arn                 = module.task_role_worker.ecs_task_role_arn
  platform_version              = var.fargate_platform_version
  aws_log_group                 = module.log_group_worker.log_group_name
  aws_log_stream                = module.log_group_worker.log_stream_name
  alb_dns_name                  = module.alb.alb_dns_name
  dns_record_name               = aws_route53_record.jenkins_dns.name
  depends_on                    = [aws_route53_record.jenkins_dns]

}

module "network" {
  source               = "../modules/nclouds_tf_network"
  identifier           = var.identifier
  workspace            = terraform.workspace
  vpc_cidr             = var.vpc_settings["cidr"]
  enable_dns_hostnames = var.vpc_settings["dns_hostnames"]
  private_subnets      = var.vpc_settings["private_subnets"]
  public_subnets       = var.vpc_settings["public_subnets"]
  endpoint_sg          = [module.security.secrets_ep_security_group_id]
  tags                 = local.tags
}

module "security" {
  source                  = "../modules/nclouds_tf_security_groups"
  identifier              = var.identifier
  workspace               = terraform.workspace
  vpc_id                  = module.network.vpc_id
  jenkins_controller_port = var.jenkins_controller_port
  tags                    = local.tags
}

module "alb" {
  source                  = "../modules/nclouds_tf_alb"
  identifier              = var.identifier
  workspace               = terraform.workspace
  subnet_ids              = module.network.public_subnet_ids
  lb_security_group_id    = module.security.lb_security_group_id
  ecs_security_group_id   = module.security.ecs_tasks_security_group_id
  vpc_id                  = module.network.vpc_id
  health_check_path       = var.health_check_path
  jenkins_controller_port = var.jenkins_controller_port
  tags                    = local.tags
  certificate_arn         = data.aws_acm_certificate.issued.arn
  depends_on              = [ data.aws_acm_certificate.issued ]
}

module "efs" {
  source                = "../modules/nclouds_tf_efs"
  identifier            = var.identifier
  tags                  = local.tags
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  ecs_security_group_id = module.security.ecs_tasks_security_group_id
  depends_on            = [module.network, module.security]
}

resource "aws_route53_record" "jenkins_dns" {
  zone_id  = data.aws_route53_zone.selected.id
  name     = "jenkins-server.com"
  type     = "A"
  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
  depends_on = [ module.alb, data.aws_route53_zone.selected ]
}
