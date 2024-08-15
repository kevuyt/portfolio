resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "portfolio-frontend-kataria"
}

resource "aws_s3_bucket_object" "portfolio_files" {
  for_each = fileset("${path.module}/../portfolio-website/dist", "**/*")
  bucket   = aws_s3_bucket.frontend_bucket.bucket
  key      = each.value
  source   = "${path.module}/../portfolio-website/dist/${each.value}"
  acl      = "public-read"
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.frontend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.frontend_bucket.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "controls" {
  bucket = aws_s3_bucket.frontend_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "PAB" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "ACL" {
  depends_on = [
    aws_s3_bucket_ownership_controls.controls,
    aws_s3_bucket_public_access_block.PAB,
  ]

  bucket = aws_s3_bucket.frontend_bucket.id
  acl    = "public-read"
}