resource "aws_dynamodb_table" "example" {
  name           = "example"
  read_capacity  = 5
  write_capacity = 5
  point_in_time_recovery {
    enabled = false
  }
}
