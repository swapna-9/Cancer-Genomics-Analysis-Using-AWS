# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# ---------------------------------
# S3 Buckets
# ---------------------------------
resource "aws_s3_bucket" "raw_bucket" {
  bucket = var.s3_raw_bucket
  acl    = "private"
}

resource "aws_s3_bucket" "processed_bucket" {
  bucket = var.s3_processed_bucket
  acl    = "private"
}

# ---------------------------------
# AWS Glue Data Catalog Database
# ---------------------------------
resource "aws_glue_catalog_database" "genomics_db" {
  name = "${var.project_name}_database"
}

# ---------------------------------
# AWS Glue Crawler
# ---------------------------------
resource "aws_glue_crawler" "genomics_crawler" {
  name               = var.glue_crawler_name
  database_name      = aws_glue_catalog_database.genomics_db.name
  role               = aws_iam_role.glue_service_role.arn
  table_prefix       = "genomics_"
  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  s3_target {
    path = "s3://${aws_s3_bucket.raw_bucket.bucket}/"
  }
}

# ---------------------------------
# AWS Glue Job
# ---------------------------------
resource "aws_glue_job" "genomics_etl_job" {
  name       = var.glue_job_name
  role       = aws_iam_role.glue_service_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.raw_bucket.bucket}/scripts/etl_script.py"
    python_version  = "3"
  }
  default_arguments = {
    "--TempDir"        = "s3://${aws_s3_bucket.processed_bucket.bucket}/tmp"
    "--job-language"   = "python"
    "--enable-continuous-cloudwatch-log" = "true"
  }
  glue_version     = "3.0"
  worker_type      = "G.1X"
  number_of_workers = 2
}

# ---------------------------------
# Lambda Function
# ---------------------------------
resource "aws_lambda_function" "trigger_crawler" {
  function_name = var.lambda_function_name
  runtime       = var.lambda_runtime
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_service_role.arn
  filename      = "lambda_code.zip"  # Replace with the path to your zipped Lambda function code
  environment {
    variables = {
      GLUE_CRAWLER_NAME = aws_glue_crawler.genomics_crawler.name
    }
  }
}

# Lambda Permission to Trigger by S3
resource "aws_lambda_permission" "s3_trigger" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_crawler.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_bucket.arn
}

# S3 Event Notification for Lambda Trigger
resource "aws_s3_bucket_notification" "raw_bucket_notification" {
  bucket = aws_s3_bucket.raw_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.trigger_crawler.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# ---------------------------------
# IAM Roles and Policies
# ---------------------------------
resource "aws_iam_role" "glue_service_role" {
  name = "${var.project_name}_glue_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "glue_policy" {
  name        = "${var.project_name}_glue_policy"
  description = "Policy for Glue to access S3 buckets and catalog"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:*"],
        Resource = ["arn:aws:s3:::${aws_s3_bucket.raw_bucket.bucket}/*", "arn:aws:s3:::${aws_s3_bucket.processed_bucket.bucket}/*"]
      },
      {
        Effect   = "Allow",
        Action   = ["glue:*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}

resource "aws_iam_role" "lambda_service_role" {
  name = "${var.project_name}_lambda_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.project_name}_lambda_policy"
  description = "Policy for Lambda to trigger Glue Crawler"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["glue:StartCrawler"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["logs:*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_service_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
