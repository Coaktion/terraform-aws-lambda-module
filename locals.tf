locals {
  # -------------------------------------------
  ############# SQS Event Mapping #############
  # -------------------------------------------
  queue_name    = var.lambda.sqs_event_mapping != null ? var.resources_prefix != null ? "${var.resources_prefix}__${var.lambda.sqs_event_mapping.queue_name}" : var.lambda.sqs_event_mapping.queue_name : null
  queue         = var.lambda.sqs_event_mapping != null ? data.aws_sqs_queue.this[local.queue_name] : null
  queue_failure = var.lambda.sqs_event_mapping != null ? data.aws_sqs_queue.this_failure[local.queue_name] : null

  sqs_policy = var.lambda.sqs_event_mapping != null ? {
    effect    = "Allow"
    resources = [local.queue.arn, local.queue_failure.arn]

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
  } : null

  # -----------------------------------------
  ############# Lambda Function #############
  # -----------------------------------------
  function_name = var.resources_prefix != null ? "${var.resources_prefix}__${var.lambda.name}" : var.lambda.name

  function_triggers = var.lambda.sqs_event_mapping != null ? {
    sqs = {
      principal  = "sqs.amazonaws.com"
      source_arn = local.queue.arn
    }
  } : null

  function_policies = var.lambda.policies != null ? local.sqs_policy != null ? merge(
    var.lambda.policies, { sqs = local.sqs_policy }
  ) : var.lambda.policies : local.sqs_policy

  # ------------------------------------------
  ############# S3 Package Bucket ############
  # ------------------------------------------
  bucket_name = var.lambda.s3.bucket != null ? var.resources_prefix != null ? "${var.resources_prefix}__${var.lambda.s3.bucket}" : var.lambda.s3.bucket : null

  s3_bucket = var.lambda.s3 != null ? try(
    data.aws_s3_bucket.this[local.lambda.s3.bucket], null
  ) != null ? data.aws_s3_bucket.this[local.lambda.s3.bucket] : resource.aws_s3_bucket.this[local.lambda.s3.bucket] : null

  s3_object = var.lambda.s3 != null ? try(
    data.aws_s3_object.this[local.lambda.s3.bucket], null
  ) != null ? data.aws_s3_object.this[local.lambda.s3.bucket] : resource.aws_s3_object.this[local.lambda.s3.bucket] : null
}
