data "aws_ssm_parameter" "roboshop_vpc_id" {
  name = "/roboshop/vpc_id"
}

data "aws_ssm_parameter" "roboshop_igw_id" {
  name = "/roboshop/roboshop_igw_id"
}

data "aws_ssm_parameter" "public_subnet_id" {
  count = 2
  name  = "/roboshop/public_subnet_id_${count.index + 1}"
}

data "aws_ssm_parameter" "private_subnet_id" {
  count = 2
  name  = "/roboshop/private_subnet_id_${count.index + 1}"
}

data "aws_ssm_parameter" "databases_subnet_id" {
  name = "/roboshop/databases_subnet_id"
}

data "aws_ssm_parameter" "nat_instance_network_interface_id" {
  name = "/roboshop/nat_instance_network_interface_id"
}
