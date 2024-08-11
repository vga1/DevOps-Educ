terraform {
  backend "s3" {
    bucket         = var.bucket
    key            = var.key
    region         = var.region
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "example" {
  ami           = "ami-0bb84b8ffd87024d8" # Replace with a valid AMI ID
  instance_type = "t2.micro"

  tags = {
    Name = "VitaliiInstance"
  }
}

module "ecr_registry" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.2.1"

  repository_name = "devops-tutor-2"
  create_lifecycle_policy = false

}

