#########################################
# S3 Bucket for Automation Screenshots
#########################################

resource "aws_s3_bucket" "screenshots" {

  bucket = "${var.project_name}-screenshots-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-screenshots"
    }
  )
}


#########################################
# S3 Bucket Ownership
#########################################

resource "aws_s3_bucket_ownership_controls" "screenshots" {

  bucket = aws_s3_bucket.screenshots.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


#########################################
# Block Public Access
#########################################

resource "aws_s3_bucket_public_access_block" "screenshots" {

  bucket = aws_s3_bucket.screenshots.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


#########################################
# Server-Side Encryption
#########################################

resource "aws_s3_bucket_server_side_encryption_configuration" "screenshots" {

  bucket = aws_s3_bucket.screenshots.id

  rule {

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}