resource "aws_ssm_parameter" "nat_instance_network_interface_id" {
  name  = "/roboshop/nat_instance_network_interface_id"
  type  = "String"
  value = aws_instance.nat_instance.primary_network_interface_id
}
