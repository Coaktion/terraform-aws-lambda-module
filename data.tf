# -----------------------------
############# SQS #############
# -----------------------------
data "aws_sqs_queue" "this" {
  for_each = local.queue_name != null ? toset([local.queue_name]) : toset([])
  name     = each.key
}

data "aws_sqs_queue" "this_failure" {
  for_each = local.queue_name != null ? toset([local.queue_name]) : toset([])
  name     = "dead__${each.key}"
}

# -----------------------------
############# S3 ##############
# -----------------------------
data "aws_s3_bucket" "this" {
  for_each = local.bucket_name != null ? toset([local.bucket_name]) : toset([])
  bucket   = each.key
}

data "aws_s3_object" "this" {
  for_each = local.bucket_name != null ? toset([local.bucket_name]) : toset([])
  bucket   = each.key
  key      = local.function_name
}
