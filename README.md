[![Known Vulnerabilities](https://snyk.io/test/github/dwp/ucfs-claimant-api-load-data/badge.svg?targetFile=src/requirements.txt)](https://snyk.io/test/github/dwp/ucfs-claimant-api-load-data?targetFile=src/requirements.txt)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=dwp_ucfs-claimant-api-load-data&metric=alert_status)](https://sonarcloud.io/dashboard?id=dwp_ucfs-claimant-api-load-data)
# ucfs-claimant-api-load-data
Python Lambda to orchestrate loading data into RDS from S3 for UCFS Claimant API service

# Note
For history prior to the creation of this repo (2020-04-24) refer to archived private repo `dip/ucfs-claimant-load-data`

## Process
1. All staging tables created by previous load are DROPPED
1. New staging tables are created 
1. Data is loaded into staging tables with PK, data, and virtual columns 
1. Any rows with a NULL IDs are removed from the staging tables
1. Unique constraints are added to the staging table ID columns
1. Indices are added
1. Live tables are renamed to `_old`
1. Staging tables are renamed to become live tables

# Building
```shell script
docker build -t dwpdigital/ucfs-claimant-api-load-data .
```

# Running
Sample manifest is provided for passing into `main.py` either directly or via `docker run` like this:
```shell script
docker run -e "LOG_LEVEL=DEBUG" -e "AWS_DEFAULT_REGION=eu-west-2" dwpdigital/ucfs-claimant-api-load-data -m $(cat manifest.json.txt)
```

```shell script
aws --profile dataworks-development --region eu-west-2 batch submit-job --job-name dan_cli --job-queue ucfs_claimant_api --job-definition ucfs_claimant_api_load_data_job --parameters manifest=$(cat manifest.json.txt)
```
