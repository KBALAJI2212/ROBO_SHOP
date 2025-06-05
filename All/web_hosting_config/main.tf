###This TF_file is related to Cloud Resume Challenge Project

resource "aws_s3_bucket_website_configuration" "switch_page" {
  bucket = "buildbucket5"

  index_document {
    suffix = var.infra == "up" ? "resume.html" : "error_resume.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "null_resource" "cloudfront_invalidation" {
  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id E1BQJ2D52ESE97 --paths /*"

  }

  triggers = {
    always_run = timestamp()
  }

}


variable "infra" {
  type    = string
  default = "up"
}
