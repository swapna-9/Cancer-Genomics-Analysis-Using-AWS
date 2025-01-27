# Cancer Hunters Project(AWS Simulation Lab)

## Overview
This project focuses on processing and analyzing cancer genomic data stored in Amazon S3 using AWS services. The data pipeline is designed to automate data extraction, transformation, and loading (ETL) processes while enabling seamless visualization with Amazon QuickSight. The project supports efficient insights into genomic mutations and cancer types, enabling advanced bioinformatics research.

### Architecture
The ETL workflow leverages the following AWS services:

#### Amazon S3:

Raw genomic data is stored in an S3 bucket (tcga-2-open).
Processed files are also stored in S3 after transformation.
#### AWS Lambda:

Monitors the S3 bucket for new uploads.
Triggers the Glue Crawlers and ETL jobs.
#### AWS Glue:

Glue Crawler: Extracts metadata from S3 and populates the Glue Data Catalog.
Glue ETL: Transforms raw genomic data for analysis and visualization.
#### Amazon QuickSight:

Directly connects to the processed data for creating dashboards and visualizations.
#### Workflow
Step 1: Raw Data Storage
Genomic data is stored in the S3 bucket.
S3 triggers the Lambda function upon detecting new data uploads.
Step 2: Trigger Crawler
AWS Lambda starts the Glue Crawler to extract metadata and populate the Glue Data Catalog.
Step 3: Data Transformation
AWS Glue ETL processes and transforms raw data into structured formats.
The transformed data is stored back in S3 for querying.
Step 4: Visualization
Amazon QuickSight visualizes the processed data for bioinformatics insights.

### Requirements
AWS Services:
Amazon S3: Data storage.
AWS Lambda: Event-driven triggers.
AWS Glue: Crawler and ETL jobs.
Amazon QuickSight: Visualization.

### Key Questions and Investigations:

#### Mutation Analysis:

Identified key cancer mutations (TP53, BRAF, KRAS) using SQL queries on genomic datasets in AWS Athena to understand their prevalence in various cancer types.
#### Cancer Type Distribution:

Analyzed cancer types and subtypes among specific demographics (e.g., females) to identify mutation-specific patterns and distributions.
#### Error and Mutation Classification:

Investigated genomic errors and non-annotated substitution mutations in cancer types (e.g., kidney cancers) using data crawling and processing pipelines.
#### Targeted Treatment Recommendations:

Proposed targeted treatment strategies for patients based on clinical DNA mutation data, leveraging structured genomic insights.
#### Data Query Optimization:

Explored structured datasets stored in S3 buckets with AWS Glue Crawlers and Data Catalog, improving data accessibility and retrieval efficiency.


### Dataset Description
The project utilizes The Cancer Genome Atlas (TCGA) dataset, a collaborative initiative by the National Cancer Institute (NCI) and the National Human Genome Research Institute (NHGRI). The TCGA dataset aims to generate comprehensive, multi-dimensional maps of genomic changes across various types and subtypes of cancer. Key highlights of the dataset include:

#### Patient Scope:

Contains matched tumor and normal tissue data from 11,000 patients.
Characterizes 33 cancer types and subtypes, including 10 rare cancers.

![Flowchart](images/flowchart.png)
