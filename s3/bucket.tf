resource "aws_s3_bucket" "s3_bucket_file" {
  bucket = "${var.prefix}-99-gsm9-file-bucket"
  force_destroy = true
  
  tags = {
    "Name" = "${var.prefix}-99-gsm9-file-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_file_bucket_public_access" {
  bucket                  = aws_s3_bucket.s3_bucket_file.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "app_src" {
  bucket = aws_s3_bucket.s3_bucket_file.id
  key = "/backend/src/app.py"
  source = "${path.module}/app/app.py"
  content_type = "application/python"
}

resource "aws_s3_object" "appspec_src" {
  bucket = aws_s3_bucket.s3_bucket_file.id
  key = "/backend/appspec.yml"
  source = "${path.module}/app/appspec.yml"
  content_type = "yaml"
}

resource "aws_s3_object" "Dockerfile_src" {
  bucket = aws_s3_bucket.s3_bucket_file.id
  key = "/backend/Dockerfile"
  source = "${path.module}/app/Dockerfile"
  content_type = "Dockerfile"
}

resource "aws_s3_object" "start_src" {
  bucket = aws_s3_bucket.s3_bucket_file.id
  key = "/backend/start_container.sh"
  source = "${path.module}/app/start_container.sh"
  content_type = "shellscript"
}

resource "aws_s3_object" "stop_src" {
  bucket = aws_s3_bucket.s3_bucket_file.id
  key = "/backend/stop_container.sh"
  source = "${path.module}/app/stop_container.sh"
  content_type = "shellscript"
}