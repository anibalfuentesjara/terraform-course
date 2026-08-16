terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

# Create a VPC
resource "aws_instance" "mi-example-instance" {
  ami           = "ami-02167eae61967e403"
  instance_type = "t2.nano"

  tags = {
    Name = "HelloWorld"
  }
}