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
resource "aws_vpc" "production-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

variable subnet_prefix {
    description = "cidr block for the subnet"
    type        = string
}

resource "aws_subnet" "subnet-1" {
  #referencia al id de la vpc
  vpc_id     = aws_vpc.production-vpc.id 
  cidr_block = var.subnet_prefix

  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "subnet-2" {
  #referencia al id de la vpc
  vpc_id     = aws_vpc.production-vpc.id 
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "subnet-2"
  }
}

output "vpc_id" {
  value = aws_vpc.production-vpc.id
}