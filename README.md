# Terraform AWS Lambda Module

Módulo Terraform para criação de AWS Lambdas. Sendo possível criar a partir de arquivos Zip com o S3, ou através de imagens docker com o ECR.

## Uso

```hcl
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  lambda_name = "my-lambda"
}

module "lambda" {
  source = "github.com/Coaktion/terraform-aws-lambda-module"

  resources_prefix = "example"

  lambda = {
    name        = local.lambda_name
    version     = "v1.0.0" # Obrigatório para lambdas .zip. Não utilizar para lambdas dockerizadas
    description = "Lambda example"

    handler     = "lambda.handler" # Obrigatório para lambdas .zip. Não utilizar para lambdas dockerizadas
    runtime     = "nodejs18.x"     # Obrigatório para lambdas .zip. Não utilizar para lambdas dockerizadas
    timeout     = 60               # Opcional, padrão => 30 segundos
    memory_size = 64               # Opcional, padrão => 128Mb

    publish = true

    policies = { # Opcional
      # "nome da policy" = {...}
      dynamodb = {
        effect = "Allow"
        actions = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]

        resources = [
          "arn:aws:dynamodb:us-east-1:123456789012:table/example-table"
        ]
      }
      # "nome da policy" = {...}
      s3 = {
        effect = "Allow"
        actions = [
          "s3:PutObject",
          "s3:GetObject"
        ]

        resources = [
          "arn:aws:s3:::example-bucket/*"
        ]
      }
    }

    environment_variables = { # Opcional
      DYNAMODB_TABLE = "example-table"
    }
  }

  s3 = { # Obrigatório para lambdas .zip. Não utilizar para lambdas dockerizadas
    bucket             = local.lambda_name
    new                = true
    local_package_path = "${local.lambda_name}.zip"
  }

  ecr = { # Obrigatório para lambdas dockerizadas. Não utilizar para lambdas .zip
    repository      = "example-repositry"
    dockerfile_path = "../"
    stage           = "example" # Opcional
  }

  sqs_event_mapping = { # Obrigatório para lambdas que consume mensagens SQS (pub/sub)
    queue_name = "example-queue"

    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping#function_response_types
    function_response_types = ["ReportBatchItemFailures"] # Opcional, padrão => ["ReportBatchItemFailures"]
    batch_size              = 1                           # Opcional, padrão => 10

    scaling_config = { # Opcional
      maximum_concurrency = 2
    }
  }

  api_gateway = { # Opcional, somente utilizado em conjunto com o módulo Terraform AWS API Gateway
    execution_arn = module.apigateway.rest_api.execution_arn
  }
}
```
