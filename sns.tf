resource "aws_sns_topic" "example" {
  name = "example-topic"
}

resource "aws_sns_topic_subscription" "example" {
  topic_arn = aws_sns_topic.example.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.example.arn
}
