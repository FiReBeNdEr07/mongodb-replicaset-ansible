terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

#selecting our region for instance
provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

# MongoDB security group
resource "aws_security_group" "mongodb" {
  name        = "mongodb"
  description = "allow ssh and mongo traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

#Launching new instance
resource "aws_instance" "mongodb_one" {
  count = 3
  ami           = "ami-0e34af9d3686f9ace"
  instance_type = "t2.large"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "mongodb-one"
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
  }
 
  security_groups = [
    "${aws_security_group.mongodb.name}"
  ]

  associate_public_ip_address = true

  key_name = "assgin-mani"
  
  
}

#creating and attaching ebs volume

resource "aws_ebs_volume" "data-vol" {
 availability_zone = "ap-south-1a"
 count = 3
 size = 100
 tags = {
        Name = "data-volume"
 }

}
##
resource "aws_volume_attachment" "mongod-vol" {
 count = 3
 device_name = "/dev/sda2"
 volume_id = "${aws_ebs_volume.data-vol.*.id[count.index]}"
 instance_id = "${element(aws_instance.mongodb_one.*.id, count.index)}"
}
