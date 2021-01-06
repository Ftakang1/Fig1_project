#Using terraform aws to dynamically assign AZs to instances 
##create ec2 on AWS
#!/bin/bash

echo "Starting EC2 Set up..."

echo "Specify number of EC2 instances to create : "
read number_of_instances

echo "You made a request for $number_of_instances to be created"

terraform validate

terraform apply -var instance_count=${number_of_instances}

resource "aws_instance" "my-ec2-instance" {
  ami             = var.ami
  count           = var.instance_count
  key_name        = var.key_name
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  security_groups = [data.aws_security_group.my-sec-group.id]

  availability_zone = ##How do I dynamically assign an availability zone here##

  tags = {
    Name    = "my-ec2-instance-tag${count.index + 1}"
    Project = "my terraform project"
  }
}

variable "availability_zone_map" {
    description = "Availability zone for instance"
    type        = map
    default     = {
        "ap-southeast-1a" = 1 
        "ap-southeast-1b" = 2
        "ap-southeast-1c" = 3
    }
        
}

resource "aws_instance" "my-ec2-instance" {
  ami             = var.ami
  count           = var.instance_count
  key_name        = var.key_name
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  security_groups = [data.aws_security_group.my-sec-group.id]
  for_each        = var.availability_zone_map
  availability_zone = each.key

  tags = {
    Name    = "my-ec2-instance-tag${count.index + 1}"
    Project = "my terraform project"
  }
}

variable "availability_zones" {
    description = "Availability zones for instance"
    type        = list
    default     = [
        "ap-southeast-1a" = 1 
        "ap-southeast-1b" = 2
        "ap-southeast-1c" = 3
    ]
        
}

resource "aws_instance" "my-ec2-instance" {
  ami             = var.ami
  count           = var.instance_count
  key_name        = var.key_name
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  security_groups = [data.aws_security_group.my-sec-group.id]
  availability_zone = var.availability_zones[ count %  var.instance_count]

  tags = {
    Name    = "my-ec2-instance-tag${count.index + 1}"
    Project = "my terraform project"
  }
}
#source: https://stackoverflow.com/questions/63007610/terraform-aws-how-to-dynamically-assign-availability-zones-to-number-of-instan
