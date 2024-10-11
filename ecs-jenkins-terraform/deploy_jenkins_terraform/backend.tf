terraform {
  required_version = ">= 1.3.6"
  backend "s3" {
    bucket               = "afg-sandbox-terraform-backend"
    region               = "us-east-1"
    key                  = "backend.tfstate"
    workspace_key_prefix = "jenkins"
    dynamodb_table       = "afg-terraform-backend"
    profile              = "afg-sandbox"
  }
}