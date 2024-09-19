provider "aws" {
  region     = "us-east-1"
}

data "aws_s3_bucket" "existing_source" {
  bucket = "sourcebucket-anisha"
}

data "aws_s3_bucket" "existing_destination" {
  bucket = "destinationbucket-anisha"
}

resource "aws_iam_role" "replication_role" {
  name = "s3-replication-role-ma36"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "replication_policy" {
  role = aws_iam_role.replication_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl"
        ],
        Resource = "arn:aws:s3:::sourcebucket-anisha/*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = "arn:aws:s3:::destinationbucket-anisha/*"
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "replication_config" {
  bucket = data.aws_s3_bucket.existing_source.id
  role   = aws_iam_role.replication_role.arn

  rule {
    id     = "replication-rule-1"
    status = "Enabled"

    filter {
      prefix = ""
    }

    destination {
      bucket        = data.aws_s3_bucket.existing_destination.arn
      storage_class = "STANDARD"
    }

      // Specify the delete marker replication configuration
      delete_marker_replication {
        status = "Enabled"  # Can be "Enabled" or "Disabled"
      }
    }
  }



