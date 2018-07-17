provider "aws" {
  region = "us-east-1"
}
provider "cloudflare" {}

terraform {
  backend "s3" {
    bucket = "terraform-backend.erosson.org"
    key    = "ch2"
    region = "us-east-1"
  }
}

resource "cloudflare_record" "ch2_erosson_org" {
  domain  = "erosson.org"
  name    = "ch2"
  type    = "CNAME"
  value   = "ch2.erosson.org.s3-website-us-east-1.amazonaws.com"
  proxied = true
}

resource "aws_s3_bucket" "ch2_erosson_org" {
  bucket = "ch2.erosson.org"
  acl    = "public-read"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::ch2.erosson.org/*"]
    }
  ]
}
POLICY

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
