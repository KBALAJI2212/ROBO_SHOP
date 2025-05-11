resource "aws_instance" "nat_instance" {

  ami                         = data.aws_ssm_parameter.roboshop_ami_id.value
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  source_dest_check           = false
  subnet_id                   = data.aws_ssm_parameter.public_subnet_id[0].value
  vpc_security_group_ids      = [data.aws_ssm_parameter.public_sg_id.value]

  root_block_device {
    volume_size = 5
  }
  user_data = base64encode(<<EOF
#!/bin/bash
sleep 20
systemctl enable squid
systemctl start squid
systemctl enable iptables
systemctl start iptables
sysctl -w net.ipv4.ip_forward=1
EOF
  )

  tags = {
    Name = "NAT_instance"
  }
}


resource "aws_vpc_security_group_egress_rule" "ssh_into_private_sg_from_public_sg" {
  security_group_id            = data.aws_ssm_parameter.public_sg_id.value
  referenced_security_group_id = data.aws_ssm_parameter.private_sg_id.value
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  description                  = "Allows SSH connections to Private SG"

}
resource "aws_vpc_security_group_egress_rule" "ssh_into_databases_sg_from_public_sg" {
  security_group_id            = data.aws_ssm_parameter.public_sg_id.value
  referenced_security_group_id = data.aws_ssm_parameter.databases_sg_id.value
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  description                  = "Allows SSH connections to Databases SG"

}



resource "aws_vpc_security_group_ingress_rule" "ssh_from_nat_instance_into_private_sg" {
  security_group_id = data.aws_ssm_parameter.private_sg_id.value
  cidr_ipv4         = "${aws_instance.nat_instance.private_ip}/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allows SSH connections from NAT Instance to Private SG"

}
resource "aws_vpc_security_group_egress_rule" "to_nat_instance_from_private_sg" {
  security_group_id = data.aws_ssm_parameter.private_sg_id.value
  cidr_ipv4         = "0.0.0.0/0" #Should use 0.0.0.0/0 instead of NAT IP and change private route to point 0.0.0/0 to NAT ID
  # from_port         = 0
  # to_port           = 65535
  ip_protocol = "-1"
  description = "Allows connections to NAT Instance"

}




resource "aws_vpc_security_group_ingress_rule" "ssh_from_nat_instance_into_databases_sg" {
  security_group_id = data.aws_ssm_parameter.databases_sg_id.value
  cidr_ipv4         = "${aws_instance.nat_instance.private_ip}/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allows SSH connections from NAT Instance into Databases SG"

}
resource "aws_vpc_security_group_egress_rule" "to_nat_instance_from_databases_sg" {
  security_group_id = data.aws_ssm_parameter.databases_sg_id.value
  cidr_ipv4         = "0.0.0.0/0" #Should use 0.0.0.0/0 instead of NAT IP and change private route to point 0.0.0/0 to NAT ID  # from_port         = 0
  # to_port           = 65535
  ip_protocol = "-1"
  description = "Allows connections to NAT Instance"

}
