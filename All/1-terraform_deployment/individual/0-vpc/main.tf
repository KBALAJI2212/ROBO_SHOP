resource "aws_vpc" "roboshop_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "roboshop_vpc"
  }
}

resource "aws_internet_gateway" "roboshop_igw" {

  vpc_id = aws_vpc.roboshop_vpc.id

  tags = {
    Name = "roboshop_internet_gateway"
  }
}


resource "aws_subnet" "databases_subnet" {
  vpc_id                  = aws_vpc.roboshop_vpc.id
  cidr_block              = var.db_sub_cidr
  map_public_ip_on_launch = false #disables public ip

  tags = {
    Name = "roboshop_database_subnet"
  }

}

resource "aws_subnet" "private_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.roboshop_vpc.id
  cidr_block              = var.private_sub_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false #disables public ip

  tags = {
    Name = "roboshop_private_subnet_${count.index + 1}"
  }

}

resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.roboshop_vpc.id
  cidr_block              = var.public_sub_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "roboshop_public_subnet_${count.index + 1}"
  }
}
