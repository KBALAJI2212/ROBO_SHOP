resource "aws_ssm_parameter" "web_tg_arn" {
  name  = "/roboshop/web_tg_arn"
  type  = "String"
  value = aws_lb_target_group.web_tg.arn
}

resource "aws_ssm_parameter" "user_tg_arn" {
  name  = "/roboshop/user_tg_arn"
  type  = "String"
  value = aws_lb_target_group.user_tg.arn
}

resource "aws_ssm_parameter" "cart_tg_arn" {
  name  = "/roboshop/cart_tg_arn"
  type  = "String"
  value = aws_lb_target_group.cart_tg.arn
}

resource "aws_ssm_parameter" "catalogue_tg_arn" {
  name  = "/roboshop/catalogue_tg_arn"
  type  = "String"
  value = aws_lb_target_group.catalogue_tg.arn
}

resource "aws_ssm_parameter" "shipping_tg_arn" {
  name  = "/roboshop/shipping_tg_arn"
  type  = "String"
  value = aws_lb_target_group.shipping_tg.arn
}

resource "aws_ssm_parameter" "payment_tg_arn" {
  name  = "/roboshop/payment_tg_arn"
  type  = "String"
  value = aws_lb_target_group.payment_tg.arn
}

resource "aws_ssm_parameter" "app_lb_dns" {
  name  = "/roboshop/app_lb_dns"
  type  = "String"
  value = aws_lb.app_lb.dns_name
}

resource "aws_ssm_parameter" "web_lb_dns" {
  name  = "/roboshop/web_lb_dns"
  type  = "String"
  value = aws_lb.web_lb.dns_name
}

resource "aws_ssm_parameter" "web_lb_zone_id" {
  name  = "/roboshop/web_lb_zone_id"
  type  = "String"
  value = aws_lb.web_lb.zone_id
}

resource "aws_ssm_parameter" "web_lb_https_listener_arn" {
  name  = "/roboshop/web_lb_https_listener_arn"
  type  = "String"
  value = aws_lb_listener.web_lb_https_listener.arn

}
