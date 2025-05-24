resource "aws_ssm_parameter" "roboshop_ami_id" {
  name  = "/roboshop/ami_id"
  type  = "String"
  value = "ami-0ce840c862563751e"
}

resource "aws_ssm_parameter" "roboshop_vpc_id" {
  name  = "/roboshop/vpc_id"
  type  = "String"
  value = aws_vpc.roboshop_vpc.id
}

resource "aws_ssm_parameter" "roboshop_igw_id" {
  name  = "/roboshop/roboshop_igw_id"
  type  = "String"
  value = aws_internet_gateway.roboshop_igw.id
}

resource "aws_ssm_parameter" "public_subnet_id" {
  count = 2
  name  = "/roboshop/public_subnet_id_${count.index + 1}"
  type  = "String"
  value = aws_subnet.public_subnet[count.index].id
}


resource "aws_ssm_parameter" "private_subnet_id" {
  count = 2
  name  = "/roboshop/private_subnet_id_${count.index + 1}"
  type  = "String"
  value = aws_subnet.private_subnet[count.index].id
}

resource "aws_ssm_parameter" "databases_subnet_id" {
  name  = "/roboshop/databases_subnet_id"
  type  = "String"
  value = aws_subnet.databases_subnet.id
}


