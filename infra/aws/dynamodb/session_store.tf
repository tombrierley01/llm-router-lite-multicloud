resource "aws_dynamodb_table" "session_store" {
  name           = "session_store"
  billing_mode   = "PAY_PER_REQUEST"
  attribute {
    name = "session_id"
    type = "S"
  }
  ... // other configurations
}