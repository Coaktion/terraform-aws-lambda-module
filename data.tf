# #################################
# ------------- SQS ------------- #
# #################################
data "aws_sqs_queue" "this" {
  for_each = local.queue_name != null ? toset([local.queue_name]) : toset([])
  name     = each.key
}

###########################################
# ------------- API Gateway ------------- #
###########################################
data "aws_api_gateway_rest_api" "this" {
  for_each = local.gtw_name != null ? toset([local.gtw_name]) : toset([])
  name     = each.key
}

##################################
# ------------- S3 ------------- #
##################################
data "aws_s3_bucket" "this" {
  for_each = local.bucket_name != null && !local.create_bucket ? toset([local.bucket_name]) : toset([])
  bucket   = each.key
}

###################################
# ------------- ECR ------------- #
###################################
data "aws_ecr_repository" "this" {
  for_each = var.ecr != null ? toset([var.ecr.repository]) : toset([])
  name     = each.key
}

data "aws_ecr_image" "this" {
  for_each        = var.ecr != null ? toset([var.ecr.repository]) : toset([])
  repository_name = each.key
  image_tag       = local.image_tag

  depends_on = [null_resource.build_docker_image]
}
