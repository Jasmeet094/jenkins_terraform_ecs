locals {
  default_tags = {
    Environment = terraform.workspace
    Name        = "${var.identifier}-${terraform.workspace}"
  }
  tags = merge(local.default_tags, var.tags)

  private_subnets = module.network.private_subnet_ids
  public_subnets  = module.network.public_subnet_ids
  container_port  = var.port_mappings[0].containerPort

}