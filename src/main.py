#!/usr/bin/python
import logging
import os
import sys

import mysql.connector
import mysql.connector.pooling
from multiprocessing import Process
import boto3
import json
import argparse


def get_parameters():
    parser = argparse.ArgumentParser(
        description="Convert S3 objects into Kafka messages"
    )

    # Parse command line inputs and set defaults
    parser.add_argument("-m", "--manifest", help="JSON objected converted to string")

    _args = parser.parse_args()

    required_args = ["manifest"]
    missing_args = []
    for required_message_key in required_args:
        if required_message_key not in _args:
            missing_args.append(required_message_key)
    if missing_args:
        raise argparse.ArgumentError(
            None,
            "ArgumentError: The following required arguments are missing: {}".format(
                ", ".join(missing_args)
            ),
        )

    return _args


def query_nino(connection, nino):
    cursor = connection.cursor()
    cursor.execute("SELECT nino FROM claimant_stage where nino = '{}'".format(nino))
    result = cursor.fetchall()
    cursor.close()
    connection.commit()
    return result


def rows_in_table(connection, table):
    cursor = connection.cursor()
    cursor.execute("SELECT count(*) FROM {}".format(table))
    result = cursor.fetchone()
    cursor.close()
    connection.commit()
    return result[0]


def execute_statement(sql):
    connection = get_connection(get_master_password())
    cursor = connection.cursor()
    cursor.execute(sql)
    logger.debug("Loaded: {}".format(cursor.rowcount))
    connection.commit()
    connection.close()


def execute_file(filename, connection, sql_parameters):
    sql = open(filename).read()

    cursor = connection.cursor()
    for result in cursor.execute(sql, sql_parameters, multi=True):
        if result.with_rows:
            logger.debug("Executed: {}".format(result.statement))
        else:
            logger.debug(
                "Executed: {}, Rows affected: {}".format(
                    result.statement, result.rowcount
                )
            )

    connection.commit()
    connection.close()


def get_master_password():
    ssm = boto3.client("ssm")
    return ssm.get_parameter(
        Name=os.environ["RDS_PASSWORD_PARAMETER_NAME"], WithDecryption=True
    )["Parameter"]["Value"]


def get_connection(password):
    return mysql.connector.connect(
        host=os.environ["RDS_ENDPOINT"],
        user=os.environ["RDS_MASTER_USERNAME"],
        password=password,
        database=os.environ["RDS_DATABASE_NAME"],
        ssl_ca="/var/task/rds-ca-2019-2015-root.pem",
        ssl_verify_cert=True,
    )


def main(manifest):
    password = get_master_password()

    post_parameters = {
        "ro_username": os.environ["RDS_RO_USERNAME"],
    }

    load_stmt = (
        "LOAD DATA FROM S3 '{}' INTO TABLE `{}_stage` FIELDS TERMINATED BY '\t' (DATA);"
    )

    logger.info("Preload started")
    execute_file("pre_load.sql", get_connection(password), {})
    logger.info("Preload finished")
    logger.info("Load started")
    processes = []

    for table, files in manifest.items():
        for file in files:
            logger.info("Loading {}".format(file))
            processes.append(
                Process(target=execute_statement, args=(load_stmt.format(file, table),))
            )

    for p in processes:
        p.start()

    for p in processes:
        p.join()
    logger.info("Load finished")
    logger.info("Sanity checking staging tables")
    for table in ["claimant_stage", "contract_stage", "statement_stage"]:
        rows = rows_in_table(get_connection(password), table)
        assert rows > 0, "check {} row count, expected > 0: got {}".format(table, rows)

    result = query_nino(get_connection(password), os.environ["TAINTED_NINO"])
    if os.environ.get("LOAD_TEST_DATA") == "True":
        logger.info("LOAD_TEST_DATA set to true")
        expectation = [(os.environ["TAINTED_NINO"],)]
    else:
        expectation = []
    assert (
        result == expectation
    ), "check for test data using hashed nino, expected {}, got {}".format(
        expectation, result
    )
    logger.info("Staging tables are sane")
    logger.info("Postload started")
    execute_file("post_load.sql", get_connection(password), post_parameters)
    logger.info("Postload finished")


if __name__ == "__main__":
    # Initialise logging
    logger = logging.getLogger(__name__)
    log_level = os.environ["LOG_LEVEL"] if "LOG_LEVEL" in os.environ else "ERROR"
    logger.setLevel(logging.getLevelName(log_level.upper()))
    logging.basicConfig(
        stream=sys.stdout,
        format="%(asctime)s %(levelname)s %(module)s "
        "%(process)s[%(thread)s] %(message)s",
    )
    logger.info("Logging at {} level".format(log_level.upper()))

    try:
        args = get_parameters()
        logger.debug(args)
        json_manifest = json.loads(args.manifest)
        logger.debug(json_manifest)
        main(json_manifest)
    except Exception as e:
        logger.error(e)
        raise e
