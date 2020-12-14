# Configure the AWS Provider
provider "aws" {
    version = "~> 3.0"
    region = "ca-central-1"
    access_key = "my-access-key"
    secret_key = "my-secret-key"
}

# Create a VPC
resource "aws_vpc" "vpc1" {
    cidr_block = "10.0.0.0/16"
    tags = {
    Name = "dev-vpc1"
  }
}

# Create Securicty Groups
resource "aws_security_group" "devsg" {
 name        = "dev-sg"
 description = "Security Group"

 ingress {
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["10.0.0.0/16"]
 }
egress {
   from_port       = 0
   to_port         = 0
   protocol        = "-1"
   cidr_blocks     = ["0.0.0.0/0"]
 }
}

# Create a subnet
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.0.0/20"
  tags = {
    Name = "dev-subnet1"
  }
}

# Create two Ec2 Instances
resource "aws_instance" "EC2-instance" {
  ami           = "ami-0e625dfca3e5a33bd"
  subnet_id     = aws_subnet.subnet1.id
  instance_type = "t2.micro"
  count         = 2
  tags = {
    Name = "Ubuntu-Instance-1"
  }
}

# Create a RDS (Mysql) database
resource "aws_db_instance" "rds-database" {
  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mysqldb"
  username             = "dbserver"
  password             = "dbserverlogin"
  parameter_group_name = "default.mysql5.7"
  # availability_zone  = "ca-central-1"
  deletion_protection  = "true"
  auto_minor_version_upgrade = "true"
  # db_subnet_group_name = "subnet1"

  tags = {
    Name = "MySqlDB"
  }
}

/*
# Provisioning an Internal-facing Load Balancer
resource "aws_lb" "lb" {
  name               = "devlb"
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id            = aws_subnet.subnet1.id
    private_ipv4_address = "10.0.1.15"
  }
  subnet_mapping {
    subnet_id            = aws_subnet.subnet2.id
    private_ipv4_address = "10.0.2.15"
  }
}
*/

# Provisioning IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc1.id
}


