provider "aws" {
  region = "eu-north-1"
}

variable "region" {
  default = "eu-north-1"
}

variable "key_name" {
  description = "Name of the key pair to use for the instances"
  default     = "AdminE2C_key" # Modify as per your key pair name
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "webserver_test" {
  name        = "WebServer Security Group"
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "WebServerSecurityGroup"
    Owner = "Oleksandr"
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0fe8bec493a81c7da" # Ubuntu 22
  instance_type          = "t3.small"
  key_name               = var.key_name
  user_data              = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install ca-certificates curl gnupg -y

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo usermod -aG docker ubuntu
    sudo systemctl restart docker

    sudo apt-get install git -y
  EOF
  vpc_security_group_ids = [aws_security_group.webserver_test.id]
  tags = {
    Name  = "Web Server"
    Owner = "Oleksandr"
  }
}

output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}
