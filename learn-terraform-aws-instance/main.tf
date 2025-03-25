terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-southeast-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0013d898808600c4a"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-0b49b45f5790e34b7"]
  subnet_id = "subnet-0201ede9e17600545"

  tags = {
    Name = "terraform_provisioned_this_not_me"
  }
}

