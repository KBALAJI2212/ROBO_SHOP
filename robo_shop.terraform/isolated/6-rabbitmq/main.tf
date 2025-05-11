resource "aws_instance" "rabbitmq" {

  ami                         = data.aws_ssm_parameter.roboshop_ami_id.value
  instance_type               = "t2.micro"
  associate_public_ip_address = false

  subnet_id              = data.aws_ssm_parameter.databases_subnet_id.value
  vpc_security_group_ids = [data.aws_ssm_parameter.databases_sg_id.value]

  root_block_device {
    volume_size = 10
  }
  user_data = file("../userdata/rabbitmq.sh")

  tags = {
    Name = "RabbitMQ_instance"
  }
}

resource "aws_ssm_parameter" "rabbitmq_ip" {
  name  = "/roboshop/rabbitmq_ip"
  type  = "String"
  value = aws_instance.rabbitmq.private_ip

}
