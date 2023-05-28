terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
resource "aws_key_pair" "IntegrationKey" {

  # Name of the key which you want to use
  key_name   = "Anurag_123"

  public_key = file("~/.ssh/id_rsa.pub")
}
# Creating a security group!
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

# Creating an AWS instance!
resource "aws_instance" "webserver" {

  # ami Id of the OS which has to be used for creating the AWS Instance.
  ami = "ami-053b0d53c279acc90"

  # Instance type for the AWS Instance
  instance_type = "t2.micro"

  # Keyname and security group are obtained from the reference of their instances
  # created above dynamically!
  key_name = aws_key_pair.IntegrationKey.key_name

  # Here security groups has to be passed in list format for the proper functioning,
  # because there might be more than 1 security groups attached to one AWS EC2 isntance!
  security_groups =  [aws_security_group.ISG.name]


  # Attaching a name to the AWS Instance!
  tags = {
    Name = "Webserver_From_Terraform"
  }

  # Establishing connection to the launched AWS instance!
  connection {

    # SSH protocol is used for accessing the AWS Instance!
    type = "ssh"
    user = "<User Name of the user which is used to access the AWS Instance>"
    private_key = file("<Path to the Key which is used to connect to AWS Instance>")

    # Public IP of the AWS Instance extracted dynamically for efficiency by taking
    # reference from the variables.
    host = aws_instance.webserver.public_ip
  }

  # Code for executing commands remotely in the AWS Instance
  # using Terraform Provisioners!
  provisioner "remote-exec" {
    # Installing Git into the system.  Here in this inline list,
    # multiple commands can be passed which
    # are required to run in the remote system.
    inline = [
      "sudo yum update -y",
      "sudo yum install git -y",
    ]
  }
}
