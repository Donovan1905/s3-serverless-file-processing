locals {
  bucket_name    = "${var.project_name}-csv-bucket"
  lambda_package = "../${path.root}/lambda.zip"
}
