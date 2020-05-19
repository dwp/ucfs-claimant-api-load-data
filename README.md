[![Known Vulnerabilities](https://snyk.io/test/github/dwp/ucfs-claimant-api-load-data/badge.svg?targetFile=requirements.txt)](https://snyk.io/test/github/dwp/ucfs-claimant-api-load-data?targetFile=requirements.txt)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=dwp_ucfs-claimant-api-load-data&metric=alert_status)](https://sonarcloud.io/dashboard?id=dwp_ucfs-claimant-api-load-data)
# ucfs-claimant-api-load-data
Python Lambda to orchestrate loading data into RDS from S3 for UCFS Claimant API service

# Note
For history prior to  the creation of this repo (2020-04-24) refer to archived private repo `dip/ucfs-claimant-load-data`

# Building
```shell script
docker build -t dwpdigital/ucfs-claimant-api-load-data .
```

# Running
Sample manifest is provided for passing into `main.py` either directly or via `docker run` like this:
```shell script
docker run -e "LOG_LEVEL=DEBUG" dwpdigital/ucfs-claimant-api-load-data -m $(cat manifest.json.txt)
```
