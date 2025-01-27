import boto3
import logging

# Initialize AWS clients
s3_client = boto3.client('s3')
glue_client = boto3.client('glue')

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function triggered by S3 file upload to start an AWS Glue Crawler.
    """
    try:
        # Log the event details
        logger.info(f"Received event: {event}")
        
        # Extract S3 bucket and object details from the event
        for record in event['Records']:
            bucket_name = record['s3']['bucket']['name']
            file_name = record['s3']['object']['key']
            logger.info(f"New file uploaded: Bucket={bucket_name}, File={file_name}")
        
        # Start the Glue Crawler
        response = glue_client.start_crawler(Name='tcga_data_crawler')
        logger.info(f"Glue Crawler 'tcga_data_crawler' started successfully. Response: {response}")
        
        return {
            'statusCode': 200,
            'body': f"Glue Crawler 'tcga_data_crawler' triggered for file {file_name}."
        }
    
    except glue_client.exceptions.CrawlerRunningException:
        logger.warning(f"Glue Crawler 'tcga_data_crawler' is already running.")
        return {
            'statusCode': 409,
            'body': f"Glue Crawler 'tcga_data_crawler' is already running."
        }
    
    except Exception as e:
        logger.error(f"Error triggering Glue Crawler: {e}")
        return {
            'statusCode': 500,
            'body': f"Error triggering Glue Crawler: {str(e)}"
        }
