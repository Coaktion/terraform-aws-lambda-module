# -----------------------------
############# SQS #############
# -----------------------------
data "aws_sqs_queue" "this" {
  for_each = local.queue_name != null ? toset([local.queue_name]) : toset([])
  name     = each.key
}

data "aws_sqs_queue" "this_dlq" {
  for_each = local.queue_name != null && var.sqs_event_mapping.with_dead_letter_queue ? toset([local.queue_name]) : toset([])
  name     = "dead__${each.key}"
}

# -----------------------------
############# S3 ##############
# -----------------------------
data "aws_s3_bucket" "this" {
  for_each = local.bucket_name != null && !local.create_bucket ? toset([local.bucket_name]) : toset([])
  bucket   = each.key
}
