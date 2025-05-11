
####PUBLIC SUBNETS ROUTES

resource "aws_route_table" "public_subnet_rt" {
  vpc_id = data.aws_ssm_parameter.roboshop_vpc_id.value

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_ssm_parameter.roboshop_igw_id.value
  }

  tags = {
    Name = "roboshop_public_subnet_routetable"
  }
}


resource "aws_route_table_association" "public_subnet_association" {
  count          = 2
  subnet_id      = data.aws_ssm_parameter.public_subnet_id[count.index].value
  route_table_id = aws_route_table.public_subnet_rt.id

}



####PRIVATE SUBNETS ROUTES

resource "aws_route_table" "private_subnet_rt" {
  vpc_id = data.aws_ssm_parameter.roboshop_vpc_id.value

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = data.aws_ssm_parameter.nat_instance_network_interface_id.value
  }

  tags = {
    Name = "roboshop_private_subnet_routetable"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = 2
  subnet_id      = data.aws_ssm_parameter.private_subnet_id[count.index].value
  route_table_id = aws_route_table.private_subnet_rt.id

}



####DATABASES SUBNETS ROUTES

resource "aws_route_table" "databases_subnet_rt" {
  vpc_id = data.aws_ssm_parameter.roboshop_vpc_id.value

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = data.aws_ssm_parameter.nat_instance_network_interface_id.value
  }

  tags = {
    Name = "roboshop_databases_subnet_routetable"
  }
}

resource "aws_route_table_association" "databases_subnet_association" {
  subnet_id      = data.aws_ssm_parameter.databases_subnet_id.value
  route_table_id = aws_route_table.databases_subnet_rt.id

}
