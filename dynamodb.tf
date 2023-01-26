resource "aws_dynamodb_table" "example" {
  name           = "example"
  read_capacity  = 5
  write_capacity = 5
  point_in_time_recovery {
    enabled = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.example.arn
        sse_algorithm     = "aws:kms"
      }
  }
}
