
resource "aws_ssm_parameter" "public_sg_id" {
  name  = "/roboshop/public_sg_id"
  type  = "String"
  value = aws_security_group.public_sg.id
}

resource "aws_ssm_parameter" "app_lb_sg_id" {
  name  = "/roboshop/app_lb_sg_id"
  type  = "String"
  value = aws_security_group.app_lb_sg.id
}

resource "aws_ssm_parameter" "private_sg_id" {
  name  = "/roboshop/private_sg_id"
  type  = "String"
  value = aws_security_group.private_sg.id
}

resource "aws_ssm_parameter" "databases_sg_id" {
  name  = "/roboshop/databases_sg_id"
  type  = "String"
  value = aws_security_group.databases_sg.id
}
