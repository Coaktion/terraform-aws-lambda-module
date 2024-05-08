module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.4.0"

  function_name = local.function_name
  description   = var.lambda.description
  handler       = var.lambda.handler
  runtime       = var.lambda.runtime
  publish       = var.lambda.publish
  timeout       = var.lambda.timeout

  create_package = false

  store_on_s3 = local.bucket_name != null
  s3_bucket   = local.bucket_name

  s3_existing_package = {
    bucket = local.s3_bucket.id
    key    = local.s3_object.id
  }


  event_source_mapping = {
    sqs = {
      event_source_arn        = local.queue.arn
      scaling_config          = var.sqs_event_mapping != null ? var.sqs_event_mapping.scaling_config : null
      function_response_types = var.sqs_event_mapping != null ? var.sqs_event_mapping.function_response_types : null
    }
  }

  allowed_triggers = local.function_triggers

  attach_policy_statements = true
  policy_statements        = local.function_policies

  environment_variables = var.lambda.environment_variables
}
