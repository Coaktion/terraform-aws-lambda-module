resource "aws_s3_bucket" "this" {
  for_each = local.bucket_name != null && local.create_bucket ? toset([local.bucket_name]) : toset([])
  bucket   = each.key
}

resource "aws_s3_object" "this" {
  for_each = local.bucket_name != null ? toset([local.bucket_name]) : toset([])

  bucket = local.create_bucket ? aws_s3_bucket.this[each.key].id : data.aws_s3_bucket.this[each.key].id
  key    = local.function_name
  source = var.s3.local_package_path
}
