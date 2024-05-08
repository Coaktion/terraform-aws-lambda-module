variable "resources_prefix" {
  description = "Prefix for resources, prefer to use the project name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "access_key_id" {
  description = "AWS Access Key used to build and push Lambda Docker image"
  type        = string
  nullable    = true
  default     = null
}

variable "secret_access_key" {
  description = "AWS Secret Access Key used to build and push Lambda Docker image"
  type        = string
  nullable    = true
  default     = null
}

variable "lambda" {
  description = "Lambda configuration"
  type = object({
    name        = string
    description = string

    handler = optional(string)
    runtime = optional(string)
    publish = bool
    timeout = number

    policies = optional(map(object({
      effect    = string
      resources = list(string)
      actions   = list(string)
    })))

    environment_variables = optional(map(string))
  })
}

variable "s3" {
  description = "Bucket for storing the Lambda package"
  type = object({
    bucket             = string
    new                = optional(bool, false)
    local_package_path = string
  })
  nullable = true
  default  = null
}

variable "ecr" {
  description = "ECR repository for storing the Lambda package"
  type = object({
    repository      = string
    dockerfile_path = string
  })
  nullable = true
  default  = null
}

variable "sqs_event_mapping" {
  description = "SQS event mapping configuration"
  type = object({
    queue_name             = string
    with_dead_letter_queue = optional(bool, false)

    function_response_types = list(string)

    scaling_config = optional(object({
      maximum_concurrency = number
    }))
  })
  nullable = true
  default  = null
}

variable "api_gateway" {
  description = "API Gateway to trigger the Lambda function"
  type = object({
    name = string
  })
  nullable = true
  default  = null
}
