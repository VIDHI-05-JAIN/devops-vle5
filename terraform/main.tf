terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_ami" "al2023" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-vle5-sg"
  description = "Security group for DevOps VLE 5"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application NodePort"
    from_port   = 30000
    to_port     = 30000
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
    Name = "DevOps-VLE5-SG"
  }
}

resource "aws_instance" "devops_server" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  key_name      = "devops-vle5-key"

  vpc_security_group_ids = [
    aws_security_group.devops_sg.id
  ]

  tags = {
    Name = "DevOps-VLE5-Server"
  }
}