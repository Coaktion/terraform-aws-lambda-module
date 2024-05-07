locals {
  # -------------------------------------------
  ############# SQS Event Mapping #############
  # -------------------------------------------
  queue_name = var.sqs_event_mapping != null ? var.resources_prefix != null ? "${var.resources_prefix}__${var.sqs_event_mapping.queue_name}" : var.sqs_event_mapping.queue_name : null
  queue      = var.sqs_event_mapping != null ? data.aws_sqs_queue.this[local.queue_name] : null
  dl_queue   = var.sqs_event_mapping != null && var.sqs_event_mapping.with_dead_letter_queue ? data.aws_sqs_queue.this_dlq[local.queue_name] : null


  sqs_policy = var.sqs_event_mapping != null ? {
    effect    = "Allow"
    resources = [local.queue.arn, local.dl_queue.arn]

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

  function_triggers = var.sqs_event_mapping != null ? {
    sqs = {
      principal  = "sqs.amazonaws.com"
      source_arn = local.queue.arn
    }
  } : null

  function_policies = var.lambda.policies != null ? merge(
    var.lambda.policies, { sqs = local.sqs_policy }
  ) : { sqs = local.sqs_policy }

  # ------------------------------------------
  ############# S3 Package Bucket ############
  # ------------------------------------------
  normalized_bucket_name = var.s3.bucket != null ? var.resources_prefix != null ? replace("${var.resources_prefix}-${var.s3.bucket}", "__", "--") : replace(var.s3.bucket, "__", "--") : null
  bucket_name            = local.normalized_bucket_name != null ? local.normalized_bucket_name : null

  create_bucket = local.bucket_name != null && var.s3.new
  s3_bucket     = local.create_bucket ? resource.aws_s3_bucket.this[local.bucket_name] : data.aws_s3_bucket.this[local.bucket_name]
  s3_object     = local.bucket_name != null ? resource.aws_s3_object.this[local.bucket_name] : null
}
