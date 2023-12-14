resource "aws_dynamodb_table" "command_table" {
  name         = "${var.project_name}-command-table"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  deletion_protection_enabled = true
}

resource "aws_dynamodb_table" "item_table" {
  name         = "${var.project_name}-item-table"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  deletion_protection_enabled = true
}
