# # S3 Bucket for Load Balancers Logs

# resource "aws_s3_bucket" "load_balancers_logs_bucket" {
#   bucket        = "load-balancers-logs5"
#   force_destroy = true
# }

# resource "aws_s3_bucket_policy" "load_balancers_logs_bucket_policy" {
#   bucket = aws_s3_bucket.load_balancers_logs_bucket.id

#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : "arn:aws:iam::127311923021:root"
#         },
#         "Action" : "s3:*",
#         "Resource" : [
#           "arn:aws:s3:::load-balancers-logs5",
#           "arn:aws:s3:::load-balancers-logs5/*"
#         ]
#       },
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "delivery.logs.amazonaws.com"
#         },
#         "Action" : "s3:*",
#         "Resource" : [
#           "arn:aws:s3:::load-balancers-logs5",
#           "arn:aws:s3:::load-balancers-logs5/*"
#         ],
#         "Condition" : {
#           "StringEquals" : {
#             "s3:x-amz-acl" : "bucket-owner-full-control"
#           }
#         }
#       },
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "delivery.logs.amazonaws.com"
#         },
#         "Action" : "s3:GetBucketAcl",
#         "Resource" : "arn:aws:s3:::load-balancers-logs5"
#       }
#     ]
#   })
# }



# # App Load-Balancer and Target Groups

# resource "aws_lb" "app_lb" {
#   name               = "app-lb"
#   load_balancer_type = "application"
#   subnets            = [data.aws_ssm_parameter.private_subnet_id[0].value, data.aws_ssm_parameter.private_subnet_id[1].value]
#   security_groups    = [data.aws_ssm_parameter.app_lb_sg_id.value]
#   internal           = true

#   access_logs {
#     bucket  = "load-balancers-logs5"
#     enabled = true
#     prefix  = "app_lb_logs"
#   }

#   depends_on = [aws_s3_bucket.load_balancers_logs_bucket]

#   tags = {
#     Name = "roboshop_app_load_balancer"
#   }

# }


# resource "aws_lb_target_group" "user_tg" {

#   name     = "user-target-group"
#   port     = 8081
#   protocol = "HTTP"
#   vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

#   health_check {
#     path                = "/health"
#     protocol            = "HTTP"
#     matcher             = "200"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#   }

#   tags = {
#     Name = "user_target_group"
#   }

# }

# resource "aws_lb_target_group" "catalogue_tg" {

#   name     = "catalogue-target-group"
#   port     = 8082
#   protocol = "HTTP"
#   vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

#   health_check {
#     path                = "/health"
#     protocol            = "HTTP"
#     matcher             = "200"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#   }

#   tags = {
#     Name = "catalogue_target_group"
#   }

# }

# resource "aws_lb_target_group" "cart_tg" {

#   name     = "cart-target-group"
#   port     = 8083
#   protocol = "HTTP"
#   vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

#   health_check {
#     path                = "/health"
#     protocol            = "HTTP"
#     matcher             = "200"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#   }

#   tags = {
#     Name = "cart_target_group"
#   }

# }

# resource "aws_lb_target_group" "shipping_tg" {

#   name     = "shipping-target-group"
#   port     = 8084
#   protocol = "HTTP"
#   vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

#   health_check {
#     path                = "/health"
#     protocol            = "HTTP"
#     matcher             = "200"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#   }

#   tags = {
#     Name = "shipping_target_group"
#   }

# }

# resource "aws_lb_target_group" "payment_tg" {

#   name     = "payment-target-group"
#   port     = 8085
#   protocol = "HTTP"
#   vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

#   health_check {
#     path                = "/health"
#     protocol            = "HTTP"
#     matcher             = "200"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#   }

#   tags = {
#     Name = "payment_target_group"
#   }

# }




# #Listener and Listener Rules

# resource "aws_lb_listener" "app_lb_listener" {
#   load_balancer_arn = aws_lb.app_lb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Request path did not match any service route."
#       status_code  = "404"
#     }
#   }

#   tags = {
#     Name = "app_load_balancer_listener"
#   }
# }


# resource "aws_lb_listener_rule" "user_listener_rule" {
#   listener_arn = aws_lb_listener.app_lb_listener.arn

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.user_tg.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/api/user/*"]
#     }
#   }

#   tags = {
#     Name = "app_lb_user_listener_rule"
#   }
# }

# resource "aws_lb_listener_rule" "cart_listener_rule" {
#   listener_arn = aws_lb_listener.app_lb_listener.arn

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.cart_tg.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/api/cart/*"]
#     }
#   }

#   tags = {
#     Name = "app_lb_cart_listener_rule"
#   }
# }

# resource "aws_lb_listener_rule" "catalogue_listener_rule" {
#   listener_arn = aws_lb_listener.app_lb_listener.arn

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.catalogue_tg.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/api/catalogue/*"]
#     }
#   }

#   tags = {
#     Name = "app_lb_catalogue_listener_rule"
#   }
# }

# resource "aws_lb_listener_rule" "shipping_listener_rule" {
#   listener_arn = aws_lb_listener.app_lb_listener.arn

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.shipping_tg.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/api/shipping/*"]
#     }
#   }

#   tags = {
#     Name = "app_lb_shipping_listener_rule"
#   }
# }

# resource "aws_lb_listener_rule" "payment_listener_rule" {
#   listener_arn = aws_lb_listener.app_lb_listener.arn

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.payment_tg.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/api/payment/*"]
#     }
#   }

#   tags = {
#     Name = "app_lb_payment_listener_rule"
#   }
# }





# # locals {
# #   services = {
# #     user      = 8081
# #     catalogue = 8082
# #     cart      = 8083
# #     shipping  = 8084
# #     payment   = 8085
# #   }
# # }

# # resource "aws_lb_target_group" "services_target_groups" {
# #   for_each = local.services

# #   name     = "${each.key}-target-group"
# #   port     = each.value
# #   protocol = "HTTP"
# #   vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

# #   health_check {
# #     path                = "/health"
# #     protocol            = "HTTP"
# #     matcher             = "200"
# #     interval            = 30
# #     timeout             = 5
# #     healthy_threshold   = 3
# #     unhealthy_threshold = 3
# #   }

# #   tags = {
# #     Name = "${each.key}_target_group"
# #   }
# # }






# # resource "aws_lb_listener_rule" "services_listener_rules" {
# #   for_each = local.services

# #   listener_arn = aws_lb_listener.app_lb_listener.arn

# #   action {
# #     type             = "forward"
# #     target_group_arn = aws_lb_target_group.services_target_groups[each.key].arn
# #   }

# #   condition {
# #     path_pattern {
# #       values = ["/api/${each.key}/*"]
# #     }
# #   }

# #   tags = {
# #     Name = "app_lb_${each.key}_listener_rule"
# #   }
# # }
