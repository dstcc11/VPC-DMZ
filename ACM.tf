locals {
  certs = ["*.kubrapoc.net", ]
}

resource "aws_acm_certificate" "certs" {
  for_each          = toset(local.certs)
  domain_name       = each.value
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}


