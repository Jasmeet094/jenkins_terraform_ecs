profile             = "aws_test-sandbox"
prod_profile        = "aws_test-production"

identifier          = "aws_test"
aws_account_id      = "890218635137" 
aws_region          = "us-east-1"
vpc_settings = {
  private_subnets = ["10.15.11.0/24", "10.15.12.0/24"]
  public_subnets      = ["10.15.8.0/24", "10.15.9.0/24"]
  dns_hostnames       = true
  dns_support         = true
  tenancy             = "default"
  cidr                = "10.15.8.0/21"
}

# Ip of the VPN
vpn_ip = "3.224.212.79/32"

tags = {
  "ManagedBy" = "terraform"
  "Infra"     = "jenkins"
}

fargate_platform_version = "1.4.0"

jenkins_controller_port = 8080

jenkins_jnlp_port       = 50000

services = {
  aws_test = {
    capacity_provider_name = "FARGATE",
    protocol               = "HTTP",
    memory                 = 4096,
    cpu                    = 2048,
    desired                = 1,
    min                    = 1,
    max                    = 1,
    min_task_capacity      = 1,
    max_task_capacity      = 3,
    health_check_port      = 8080,
    scale_threshold        = 80,
    health_check           = "/",
    iam_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
      "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
    ],
    port_mappings = [
      {
        containerPort = 8080
      },
      {
        containerPort = 50000
      }
    ],
    environment = {},
    secrets = []
  }
}