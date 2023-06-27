#STEP1: Basic Syntax
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
#STEP2: Provide AWS Region
provider "aws" {
  region = "us-east-1"
}
#STEP3: Create Key-Pair
resource "aws_key_pair" "IntegrationKey" {

  # Name of the key which you want to use
  key_name   = "Anurag_123"

  public_key = file("~/.ssh/id_rsa.pub")
}
# STEP4: Creating a security group!
resource "aws_security_group" "ISG" {

  # Write description for the security group!
  description = "Allow HTTP Inbound Traffic"
  ingress {
    description = "HTTP for webserver"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH for webserver"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "ouput from webserver"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Project1"
  }
}
# STEP 5: Create EC2 Instance
resource "aws_instance" "app_server" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform_Demo"
  }

  # Establishing connection to the launched AWS instance!
  connection {
    # SSH protocol is used for accessing the AWS Instance!
    type        = "ssh"
    user        = self.public_ip
    private_key = file("~/.ssh/id_rsa.pub")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install git -y",
    ]
  }
}

#Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}










