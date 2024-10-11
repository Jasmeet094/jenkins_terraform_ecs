locals {
  default_tags = {
    Environment = terraform.workspace
  }
  tags            = merge(local.default_tags, var.tags)
  private_subnets = values(aws_subnet.private)
  public_subnets  = values(aws_subnet.public)
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_settings["cidr"]
  enable_dns_hostnames = var.vpc_settings["dns_hostnames"]
  tags = {
    Name = "${var.identifier}-${terraform.workspace}-vpc"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  for_each                = toset(var.vpc_settings["private_subnets"])
  map_public_ip_on_launch = false
  availability_zone = element(
    data.aws_availability_zones.available.names,
    index(var.vpc_settings["private_subnets"], each.key) % length(data.aws_availability_zones.available.names),
  )
  cidr_block = each.key
  vpc_id     = aws_vpc.main.id
  tags       = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-private-${each.key}" })
}

# Create public subnets
resource "aws_subnet" "public" {
  for_each   = toset(var.vpc_settings["public_subnets"])
  cidr_block = each.key
  availability_zone = element(
    data.aws_availability_zones.available.names,
    index(var.vpc_settings["public_subnets"], each.key) % length(data.aws_availability_zones.available.names),
  )
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags                    = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-public-${each.key}" })
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-igw" })
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Create a NAT gateway with an Elastic IP for private subnets to get internet connectivity
resource "aws_eip" "nat_gw_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags       = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-eip" })
}

resource "aws_nat_gateway" "nat_gw" {
  subnet_id     = values(aws_subnet.public)[0].id
  allocation_id = aws_eip.nat_gw_eip.id
  tags          = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-nat_gw" })
}

# Create a new route table for the public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-${terraform.workspace}-public-route"
    }
  )
}

# # Explicitly associate the newly created route table to the Public subnets
resource "aws_route_table_association" "public_subnets" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

# # Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-${terraform.workspace}-private-route"
    }
  )
}

# # Explicitly associate the newly created route table to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private_subnets" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id
}

# data resource to get the service name for secrets manager
data "aws_vpc_endpoint_service" "secrets_manager" {
  service = "secretsmanager"
}

resource "aws_vpc_endpoint" "secrets_manager_ep" {
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  service_name        = data.aws_vpc_endpoint_service.secrets_manager.service_name
  subnet_ids          = local.private_subnets.*.id
  vpc_id              = aws_vpc.main.id
  security_group_ids  = var.endpoint_sg
  tags                = local.tags

  depends_on = [aws_subnet.private]
}