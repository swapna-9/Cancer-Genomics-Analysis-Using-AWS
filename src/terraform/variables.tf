# Variables for Project Name
variable "project_name" {
  description = "Name of the project"
  default     = "cancer_genomics"
}

# Variables for S3 Buckets
variable "s3_raw_bucket" {
  description = "Name of the S3 bucket for raw data"
  default     = "tcga-raw-data-bucket"
}

variable "s3_processed_bucket" {
  description = "Name of the S3 bucket for processed data"
  default     = "tcga-processed-data-bucket"
}

# Variables for AWS Glue
variable "glue_crawler_name" {
  description = "Name of the AWS Glue Crawler"
  default     = "tcga_data_crawler"
}

variable "glue_job_name" {
  description = "Name of the AWS Glue Job"
  default     = "tcga_etl_job"
}

# Variables for Region
variable "aws_region" {
  description = "AWS Region to deploy resources"
  default     = "us-east-1"
}

# Variables for Lambda
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  default     = "tcga_crawler_trigger"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  default     = "python3.8"
}
