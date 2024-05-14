provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami                    = "ami-0bb84b8ffd87024d8"
  instance_type          = "t2.micro"
  key_name               = "educ"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.example.id]

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