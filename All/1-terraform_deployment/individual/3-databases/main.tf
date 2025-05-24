resource "aws_instance" "databases" {

  ami                         = data.aws_ssm_parameter.roboshop_ami_id.value
  instance_type               = "t3.small"
  associate_public_ip_address = false

  subnet_id              = data.aws_ssm_parameter.databases_subnet_id.value
  vpc_security_group_ids = [data.aws_ssm_parameter.databases_sg_id.value]

  root_block_device {
    volume_size = 15
  }
  user_data = file("../userdata/allin1_databases.sh")

  tags = {
    Name = "databases_instance"
  }
}


resource "aws_ssm_parameter" "mongodb_ip" {
  name  = "/roboshop/mongodb_ip"
  type  = "String"
  value = aws_instance.databases.private_ip

}

resource "aws_ssm_parameter" "redis_ip" {
  name  = "/roboshop/redis_ip"
  type  = "String"
  value = aws_instance.databases.private_ip

}

resource "aws_ssm_parameter" "mysql_ip" {
  name  = "/roboshop/mysql_ip"
  type  = "String"
  value = aws_instance.databases.private_ip

}

resource "aws_ssm_parameter" "rabbitmq_ip" {
  name  = "/roboshop/rabbitmq_ip"
  type  = "String"
  value = aws_instance.databases.private_ip

}
