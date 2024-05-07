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

    package = optional(string) # Path to the Zip package

    s3 = optional(object({
      bucket             = string
      local_package_path = string
    }))

    sqs_event_mapping = optional(object({
      queue_name              = string
      function_response_types = list(string)

      scaling_config = optional(object({
        maximum_concurrency = number
      }))
    }))

    policies = optional(map(object({
      effect    = string
      resources = list(string)
      actions   = list(string)
    })))

    environment_variables = optional(map(string))
  })
}
