import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, lit, when, to_date

# Initialize Glue context and job
args = getResolvedOptions(sys.argv, ["JOB_NAME", "INPUT_PATH", "OUTPUT_PATH"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Parameters
input_path = args["INPUT_PATH"]  # S3 input path (e.g., s3://genome/raw_data/)
output_path = args["OUTPUT_PATH"]  # S3 output path (e.g., s3://genome/processed_data/)

# Load raw data from S3
print("Reading data from S3...")
raw_df = spark.read.option("header", "true").csv(input_path)

# Step 1: Remove null values
print("Removing rows with null values...")
cleaned_df = raw_df.dropna()

# Step 2: Remove duplicates
print("Removing duplicate rows...")
deduped_df = cleaned_df.dropDuplicates()

# Step 3: Standardize column names
print("Standardizing column names...")
standardized_df = deduped_df.toDF(
    *[col_name.strip().lower().replace(" ", "_") for col_name in deduped_df.columns]
)

# Step 4: Validate and format data types
print("Validating and formatting data types...")
formatted_df = standardized_df \
    .withColumn("gene_expression", col("gene_expression").cast("float")) \
    .withColumn("mutation_id", col("mutation_id").cast("int")) \
    .withColumn("date", to_date(col("date"), "yyyy-MM-dd"))

# Step 5: Handle categorical columns
print("Standardizing categorical column 'cancer_type'...")
final_df = formatted_df \
    .withColumn("cancer_type", when(col("cancer_type").isNotNull(), col("cancer_type").lower()).otherwise(lit("unknown")))

# Step 6: Partition the data by 'cancer_type' for optimized querying
print("Writing partitioned data to S3...")
final_df.write.mode("overwrite").partitionBy("cancer_type").parquet(output_path)

print(f"Transformation complete. Processed data saved to: {output_path}")

# Finalize the Glue job
job.commit()
