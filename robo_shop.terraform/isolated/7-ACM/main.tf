resource "aws_acm_certificate" "hosted_zone_cert" {
  domain_name       = "*.balaji.website"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "hosted_zone_cert_validation_records" {

  for_each = {
    for dvo in aws_acm_certificate.hosted_zone_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = "Z04307862A5Z0E82KA5RX"
}

resource "aws_acm_certificate_validation" "hosted_zone_cert_validation" {
  certificate_arn         = aws_acm_certificate.hosted_zone_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.hosted_zone_cert_validation_records : record.fqdn]
}

