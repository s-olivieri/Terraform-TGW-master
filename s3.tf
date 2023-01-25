#This template creates an S3 bucket named "example-bucket" and sets its access control list (ACL) to "public-read" which allows all objects in the bucket to be publicly readable. It also creates an S3 bucket policy that allows all principals to perform the "s3:GetObject" action on all objects in the bucket. Keep in mind that this bucket will not be encrypted and all the data stored will be in clear text.

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicReadAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::example-bucket/*"
      ]
    }
  ]
}
EOF
}
