variable "resources_prefix" {
  description = "Prefix for resources, prefer to use the project name"
  type        = string
}

variable "lambda" {
  description = "Lambda configuration"
  type = object({
    name        = string
    description = string

    handler = string
    runtime = string
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
