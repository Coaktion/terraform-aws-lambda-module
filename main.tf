module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.4.0"

  function_name = local.function_name
  description   = var.lambda.description

  handler     = var.lambda.handler
  runtime     = var.lambda.runtime
  timeout     = var.lambda.timeout
  memory_size = var.lambda.memory_size

  publish = var.lambda.publish

  create_package = false
  package_type   = var.ecr != null ? "Image" : "Zip"

  store_on_s3 = local.bucket_name != null
  s3_bucket   = local.bucket_name

  s3_existing_package = var.s3 != null ? {
    bucket = local.s3_bucket.id
    key    = local.s3_object.id
  } : null

  image_uri = var.ecr != null ? data.aws_ecr_image.this[var.ecr.repository].image_uri : null

  event_source_mapping = local.queue != null ? {
    sqs = {
      event_source_arn        = local.queue.arn
      batch_size              = var.sqs_event_mapping.batch_size
      scaling_config          = var.sqs_event_mapping.scaling_config
      function_response_types = var.sqs_event_mapping.function_response_types
    }
  } : {}

  allowed_triggers = local.function_triggers

  attach_policy_statements = length(keys(local.function_policies)) > 0
  policy_statements        = local.function_policies

  environment_variables = var.lambda.environment_variables
}
