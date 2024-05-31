provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "web_server_role" {
  name = "web-server_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "secrets_manager_policy"
  description = "Policy to allow access to Secrets Manager"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecrets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy" {
  role       = aws_iam_role.web_server_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

resource "aws_iam_instance_profile" "web_server_instance_profile" {
  name = "web-server_instance_profile"
  role = aws_iam_role.web_server_role.name
}

resource "aws_instance" "example" {
  ami                    = "ami-0bb84b8ffd87024d8"
  instance_type          = "t2.micro"
  key_name               = "educ"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.example.id]
  iam_instance_profile   = aws_iam_instance_profile.web_server_instance_profile.name

  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y docker jq
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Get secret from AWS Secrets Manager
SECRET_NAME="my-test-secret"
SECRET=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query SecretString --output text)

# Write secret to .env file
echo "" > /home/ec2-user/.env
sudo chown ec2-user:ec2-user .env
echo "$SECRET" > /home/ec2-user/.env
EOF

  tags = {
    Name = "Education-instance"
  }
}

resource "aws_security_group" "example" {
  name        = "Education-security-group"
  description = "Education security group for EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["86.111.79.24/32"] # Replace with your home IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "example" {
  key_name   = "your_ssh_key_name"
  public_key = file("~/.ssh/id_ed25519.pub") # Path to your SSH public key
}

resource "null_resource" "example" {
  depends_on = [aws_instance.example]

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ec2-user",
      "sudo curl -L https://github.com/docker/compose/releases/download/your_docker_compose_version/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/educ.pem") # Path to your SSH private key
      host        = aws_instance.example.public_ip
    }
  }
}