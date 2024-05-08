resource "null_resource" "build_docker_image" {
  for_each = var.ecr != null ? toset([var.ecr.repository]) : toset([])

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${data.aws_ecr_repository.this[each.key].repository_url}"
    environment = {
      AWS_ACCESS_KEY_ID     = var.access_key_id
      AWS_SECRET_ACCESS_KEY = var.secret_access_key
      AWS_DEFAULT_REGION    = var.region
    }
  }

  provisioner "local-exec" {
    command = "docker build -t ${local.function_name}:latest ${var.ecr.dockerfile_path}"
    environment = {
      AWS_ACCESS_KEY_ID     = var.access_key_id
      AWS_SECRET_ACCESS_KEY = var.secret_access_key
      AWS_DEFAULT_REGION    = var.region
    }
  }

  provisioner "local-exec" {
    command = "docker tag ${local.function_name}:latest ${data.aws_ecr_repository.this[each.key].repository_url}:latest"
    environment = {
      AWS_ACCESS_KEY_ID     = var.access_key_id
      AWS_SECRET_ACCESS_KEY = var.secret_access_key
      AWS_DEFAULT_REGION    = var.region
    }
  }

  provisioner "local-exec" {
    command = "docker push ${data.aws_ecr_repository.this[each.key].repository_url}:latest"
    environment = {
      AWS_ACCESS_KEY_ID     = var.access_key_id
      AWS_SECRET_ACCESS_KEY = var.secret_access_key
      AWS_DEFAULT_REGION    = var.region
    }
  }
}
