resource "aws_cloudfront_distribution" "static-www-nike-dev" {
    origin {
        domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
        origin_id = aws_s3_bucket.bucket.id
        s3_origin_config {
          origin_access_identity = aws_cloudfront_origin_access_identity.static-www-nike-dev.cloudfront_access_identity_path
        }
    }

    enabled =  true

    default_root_object = "index.html"

    default_cache_behavior {
        allowed_methods = [ "GET", "HEAD" ]
        cached_methods = [ "GET", "HEAD" ]
        target_origin_id = aws_s3_bucket.bucket.id
        
        forwarded_values {
            query_string = false

            cookies {
              forward = "none"
            }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }

    restrictions {
      geo_restriction {
          restriction_type = "whitelist"
          locations = [ "JP" ]
      }
    }
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}

resource "aws_cloudfront_origin_access_identity" "static-www-nike-dev" {}


resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "static-www-nike-dev"
  acl = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "bucket" {
    bucket = aws_s3_bucket.bucket.id
    policy = data.aws_iam_policy_document.static-www-nike-dev.json
}

data "aws_iam_policy_document" "static-www-nike-dev" {
  statement {
    sid = "Allow CloudFront"
    effect = "Allow"
    principals {
        type = "AWS"
        identifiers = [aws_cloudfront_origin_access_identity.static-www-nike-dev.iam_arn]
    }
    actions = [
        "s3:GetObject"
    ]

    resources = [
        "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_object" "index_page" {
  bucket = aws_s3_bucket.bucket.id
  key = "index.html"
  source = "main.html"
  content_type = "text/html"
  etag = filemd5("main.html")
}

resource "aws_s3_bucket_object" "index_js" {
  bucket = aws_s3_bucket.bucket.id
  key = "main.js"
  source = "main.js"
  content_type = "text/jsvascript"
  etag = filemd5("main.js")
}
