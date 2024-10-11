profile             = "aws-sandbox"
prod_profile        = "aws-production"

identifier          = "jenkins"
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

tags = {
  "ManagedBy" = "terraform"
  "Infra"     = "jenkins"
}

fargate_platform_version = "1.4.0"

jenkins_controller_port = 8080

jenkins_jnlp_port       = 50000

services = {
  jenkins = {
    capacity_provider_name = "FARGATE_SPOT",
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
    secrets = [
      {
        name      = "JENKINS_ADMIN_PWD",
        valueFrom = "arn:aws:secretsmanager:us-east-1:AWSACCOUNTID:secret:JENKINS_ADMIN_PWD-TJvmlg"
      }
    ]
  }
}