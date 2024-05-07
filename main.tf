module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.4.0"

  function_name = local.function_name
  description   = var.lambda.description
  handler       = var.lambda.handler
  runtime       = var.lambda.runtime
  publish       = true

  create_package = false

  store_on_s3 = true
  s3_bucket   = local.bucket_name

  s3_existing_package = {
    bucket = local.s3_bucket.id
    key    = local.s3_object.id
  }


  event_source_mapping = {
    sqs = {
      event_source_arn = local.queue.arn
      scaling_config   = var.lambda.sqs_event_mapping.scaling_config

      function_response_types = var.lambda.sqs_event_mapping.function_response_types
    }
  }

  allowed_triggers = local.function_triggers

  attach_policy_statements = true
  policy_statements        = local.function_policies

  environment_variables = var.lambda.environment_variables
}
