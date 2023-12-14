module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.2.0"

  function_name = "${var.project_name}-process-sales-data"
  runtime       = "python3.11"
  handler       = "src.file_processing_handler.lambda_handler"
  lambda_role   = aws_iam_role.iam_for_lambda.arn
  create_role   = false
  environment_variables = {
    "REGION"        = var.region,
    "ITEM_TABLE"    = aws_dynamodb_table.item_table.name,
    "COMMAND_TABLE" = aws_dynamodb_table.command_table.name
  }

  memory_size = 1028
  timeout     = 30

  create_package = false
  s3_existing_package = {
    bucket = aws_s3_bucket.builds.id
    key    = aws_s3_object.lambda_package.id
  }
}

resource "aws_s3_object" "lambda_package" {
  bucket = aws_s3_bucket.builds.id
  key    = "${filemd5(local.lambda_package)}.zip"
  source = local.lambda_package
}

resource "aws_lambda_permission" "s3_lambda_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.bucket.id}"
}
