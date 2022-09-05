data "aws_partition" "this" {}

locals {
  table_name = "${var.account_id}${var.table_name_postfix}"
  role_name  = "${var.account_id}${var.table_name_postfix}-role"

  role_arn_param_path           = "/${var.context}/fls/monitoring/dynamodb/${var.account_id}/role_arn"
  role_arn_param_description    = "Role arn for lambda to assume"
  role_name_param_path           = "/${var.context}/fls/monitoring/dynamodb/${var.account_id}/role_name"
  role_name_param_description    = "Role name to allow working account ${var.account_id} to access dynamodb table"
  table_name_param_path          = "/${var.context}/fls/monitoring/dynamodb/${var.account_id}/table_name"
  table_name_param_description   = "DynamoDB table name for receiving logs from account ${var.account_id}"
  row_id_name_param_path         = "/${var.context}/fls/monitoring/dynamodb/${var.account_id}/row_id_name"
  row_id_name_param_description  = "Unique column name for DynamoDB table for receiving logs from account ${var.account_id}"
  time_to_live_param_path        = "/${var.context}/fls/monitoring/dynamodb/${var.account_id}/time_to_live"
  time_to_live_param_description = "Time to live column name for DynamoDB table for receiving logs from account ${var.account_id}"
}

resource "aws_dynamodb_table" "this" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.table_hash_key

  attribute {
    name = "row_id"
    type = "S"
  }

  ttl {
    attribute_name = var.table_time_to_live
    enabled        = true
  }

  stream_enabled   = "true"
  stream_view_type = "NEW_IMAGE"
  tags = merge(
    var.fixed_tags,
    {
      context = var.context
    }
  )
}

resource "aws_iam_role" "this" {
  name = local.role_name
  tags = merge(
    var.fixed_tags,
    {
      purpose = var.purpose
    }
  )
  assume_role_policy = data.aws_iam_policy_document.allow_assum_role.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}


resource "aws_iam_policy" "this" {
  name   = "${var.context}-${var.account_id}-dynamodb-access"
  path   = "/"
  policy = data.aws_iam_policy_document.access_dynamodb_policy.json
}

data "aws_iam_policy_document" "access_dynamodb_policy" {
  statement {
    sid = "1"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:UpdateItem",
      "dynamodb:PutItem",
      "dynamodb:BatchWriteItem"
    ]
    resources = [
      aws_dynamodb_table.this.arn
    ]
  }
}

data "aws_iam_policy_document" "allow_assum_role" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.this.partition}:iam::${var.account_id}:root"]
    }
  }
}

resource "aws_ssm_parameter" "this_role_arn" {
  name        = local.role_arn_param_path
  description = local.role_arn_param_description
  type        = "String"
  value       = aws_iam_role.this.arn
  overwrite   = true
  data_type   = "text"
  tags = merge(
    var.fixed_tags
  )
}

resource "aws_ssm_parameter" "this_role_name" {
  name        = local.role_name_param_path
  description = local.role_name_param_description
  type        = "String"
  value       = aws_iam_role.this.name
  overwrite   = true
  data_type   = "text"
  tags = merge(
    var.fixed_tags
  )
}

resource "aws_ssm_parameter" "this_table_name" {
  name        = local.table_name_param_path
  description = local.table_name_param_description
  type        = "String"
  value       = aws_dynamodb_table.this.name
  overwrite   = true
  data_type   = "text"
  tags = merge(
    var.fixed_tags
  )
}

resource "aws_ssm_parameter" "this_row_id_name" {
  name        = local.row_id_name_param_path
  description = local.row_id_name_param_description
  type        = "String"
  value       = aws_dynamodb_table.this.hash_key
  overwrite   = true
  data_type   = "text"
  tags = merge(
    var.fixed_tags
  )
}

resource "aws_ssm_parameter" "this_time_to_live" {
  name        = local.time_to_live_param_path
  description = local.time_to_live_param_description
  type        = "String"
  value       = var.table_time_to_live
  overwrite   = true
  data_type   = "text"
  tags = merge(
    var.fixed_tags
  )
}
