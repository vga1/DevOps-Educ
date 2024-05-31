provider "aws" {
  region = "us-east-1" # Specify your region
}

# Import the secret manager module
module "secrets" {
  source = "./modules/secret_manager"
}

# Import the EC2 module
module "ec2" {
  source = "./modules/ec2"
}

# Get current account information using aws_caller_identity data source
data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_account_arn" {
  value = data.aws_caller_identity.current.arn
}

output "aws_account_name" {
  value = data.aws_caller_identity.current.user_id
}

output "secret_arn" {
  value = module.secrets.secret_arn
}