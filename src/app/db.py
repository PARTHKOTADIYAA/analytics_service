"""
DB connection + insert helper.

Credentials are pulled from Secrets Manager once per Lambda execution
environment (cached across warm invocations) rather than on every request.
"""
import json
import os
from functools import lru_cache

import boto3
import pymysql

DB_HOST = os.environ["DB_HOST"]
DB_PORT = int(os.environ.get("DB_PORT", 3306))
DB_NAME = os.environ["DB_NAME"]
DB_SECRET_ARN = os.environ["DB_SECRET_ARN"]


@lru_cache(maxsize=1)
def _get_credentials():
    client = boto3.client("secretsmanager")
    secret = client.get_secret_value(SecretId=DB_SECRET_ARN)
    return json.loads(secret["SecretString"])


@lru_cache(maxsize=1)
def _get_connection():
    creds = _get_credentials()
    return pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=creds["username"],
        password=creds["password"],
        database=DB_NAME,
        autocommit=True,
        connect_timeout=5,
    )


def insert_event(
    event_id,
    event_time,
    event_type,
    user_id,
    session_id,
    product_id,
    page_url,
    search_term,
    source,
    metadata,
):
    conn = _get_connection()
    with conn.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO user_behavior_events
                (event_id, event_time, user_id, session_id, event_type,
                 product_id, page_url, search_term, source, metadata_json)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (
                event_id,
                event_time,
                user_id,
                session_id,
                event_type,
                product_id,
                page_url,
                search_term,
                source,
                json.dumps(metadata) if metadata else None,
            ),
        )
