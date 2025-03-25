# Purpose: Specifies the cloud provider and region where resources will be created.
provider "aws" {
  region = "ap-southeast-1"
}

# Purpose: Creates a Virtual Private Cloud (VPC) in AWS.
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "ansible_terraform_demo_VPC"
  }
}

# Purpose: Creates a subnet within the VPC. 
#[vpc_id = aws_vpc.example.id: Links the subnet to the previously created VPC.]
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.0.0/28"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "terrform_ansible_PublicSubnet"
  }
}

# Purpose: Creates an internet gateway (IGW) for the VPC. 
#[vpc_id = aws_vpc.example.id: Attaches the IGW to the VPC.]
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "terraform_ansible_IGW"
  }
}

# Purpose: Creates a route table for the VPC. 
#[vpc_id = aws_vpc.example.id: Links the route table to the VPC.]
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

# Defines a route to the internet gateway for all traffic (0.0.0.0/0).
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "TxA_PublicRouteTable"
  }
}

# Purpose: Associates the route table with the subnet. 
# subnet_id = aws_subnet.public.id: Specifies the subnet to associate.
#route_table_id = aws_route_table.public.id: Specifies the route table to use.

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Purpose: Creates a security group for controlling inbound and outbound traffic.
# vpc_id = aws_vpc.example.id: Links the security group to the VPC.
# ingress: Defines rules for incoming traffic.
#   Port 22 allows SSH access from anywhere.
#   Port 80 allows HTTP access from anywhere.
# egress: Defines rules for outgoing traffic; here, all traffic is allowed.

resource "aws_security_group" "example" {
  name        = "terraform_ansible_demo_sg"
  description = "Terraform and Ansible Demo security group"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# Purpose: Creates an EC2 instance.
# subnet_id = aws_subnet.public.id: Places the instance in the public subnet.
# vpc_security_group_ids = [aws_security_group.example.id]: Applies the previously created security group.
# key_name = "your_key_name": Specifies the SSH key pair to use for access.

resource "aws_instance" "example" {
  ami           = "ami-0b5a4445ada4a59b1"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.example.id]
  key_name               = "terraform_ansible_key"

  tags = {
    Name = "terraform_did_it_not_me"
  }
}