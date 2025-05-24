resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "SG for instances in Public Subnet."
  vpc_id      = data.aws_ssm_parameter.roboshop_vpc_id.value
  egress      = []

  tags = {
    Name = "roboshop_public_security_group"
  }
}
resource "aws_vpc_security_group_ingress_rule" "from_internet_to_public_sg" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  # from_port         = 0
  # to_port           = 65535
  ip_protocol = "-1"
  description = "Allows all connections from internet to instances attached with Public SG"

}
resource "aws_vpc_security_group_egress_rule" "to_internet_from_public_sg" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  # from_port         = 0
  # to_port           = 65535
  ip_protocol = "-1"
  description = "Allows all connections to internet for instances attached with Public SG"

}
resource "aws_vpc_security_group_egress_rule" "to_app_lb_sg_from_public_sg" {
  security_group_id            = aws_security_group.public_sg.id
  referenced_security_group_id = aws_security_group.app_lb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Allows connections to App Load-Balancer SG on port 80"

}



resource "aws_security_group" "app_lb_sg" {
  name        = "app_load_balancer_sg"
  description = "SG for App LB."
  vpc_id      = data.aws_ssm_parameter.roboshop_vpc_id.value
  egress      = []

  tags = {
    Name = "roboshop_app_load_balancer_security_group"
  }
}
resource "aws_vpc_security_group_ingress_rule" "from_public_sg_to_app_lb_sg" {
  security_group_id            = aws_security_group.app_lb_sg.id
  referenced_security_group_id = aws_security_group.public_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Allows connections from Public SG on port 80 via TCP"

}
resource "aws_vpc_security_group_ingress_rule" "from_private_sg_to_app_lb_sg" {
  security_group_id            = aws_security_group.app_lb_sg.id
  referenced_security_group_id = aws_security_group.private_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Allows connections from Private SG on port 80 via TCP"

}
resource "aws_vpc_security_group_egress_rule" "to_private_sg_from_app_lb_sg" {
  security_group_id            = aws_security_group.app_lb_sg.id
  referenced_security_group_id = aws_security_group.private_sg.id
  from_port                    = 8081
  to_port                      = 8085
  ip_protocol                  = "tcp"
  description                  = "Allows connections to Private SG on ports 8081-8085 via TCP"

}





resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "SG for instances in Private Subnet."
  vpc_id      = data.aws_ssm_parameter.roboshop_vpc_id.value
  egress      = []

  tags = {
    Name = "roboshop_private_security_group"
  }
}
resource "aws_vpc_security_group_ingress_rule" "from_app_lb_sg_to_private_sg" {
  security_group_id            = aws_security_group.private_sg.id
  referenced_security_group_id = aws_security_group.app_lb_sg.id
  from_port                    = 8081
  to_port                      = 8085
  ip_protocol                  = "tcp"
  description                  = "Allows connections from App LB SG on ports 8081-8085 via TCP only"

}
resource "aws_vpc_security_group_egress_rule" "into_databases_sg_from_private_sg" {

  security_group_id            = aws_security_group.private_sg.id
  referenced_security_group_id = aws_security_group.databases_sg.id
  # from_port                    = 0
  # to_port                      = 65535
  ip_protocol = "-1"
  description = "Allows connections to instances attached with Databases SG"

}
resource "aws_vpc_security_group_egress_rule" "into_app_lb_sg_from_private_sg" {

  security_group_id            = aws_security_group.private_sg.id
  referenced_security_group_id = aws_security_group.app_lb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Allows connections to App LB SG on port 80 via TCP only"

}





resource "aws_security_group" "databases_sg" {

  name        = "databases_sg"
  description = "SG for databases that allows connections only from private security group"
  vpc_id      = data.aws_ssm_parameter.roboshop_vpc_id.value
  egress      = []

  tags = {
    Name = "roboshop_databases_security_group"
  }
}
resource "aws_vpc_security_group_ingress_rule" "from_private_sg_into_databases_sg" {
  security_group_id            = aws_security_group.databases_sg.id
  referenced_security_group_id = aws_security_group.private_sg.id
  # from_port                    = 0
  # to_port                      = 65535
  ip_protocol = "-1"
  description = "Allows connections from Private SG"
}

