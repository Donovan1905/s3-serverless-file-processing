from datetime import datetime

import boto3
import os
import botocore
import json
import csv
import uuid

s3 = boto3.client('s3')


def lambda_handler(event, context):
    local_filename = "/tmp/filename.csv"

    dynamodb = boto3.resource('dynamodb')
    item_table = dynamodb.Table(os.environ['ITEM_TABLE'])
    command_table = dynamodb.Table(os.environ['COMMAND_TABLE'])

    s3 = boto3.client('s3')
    BUCKET_NAME = event["Records"][0]["s3"]["bucket"]["name"]
    S3_KEY = event["Records"][0]["s3"]["object"]["key"]

    print(BUCKET_NAME)
    print(S3_KEY)

    try:
        s3.download_file(BUCKET_NAME, S3_KEY, local_filename)
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == "404":
            print("The object does not exist: s3://" + BUCKET_NAME + S3_KEY)

    with open(local_filename, mode='r') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        total_price = 0
        command_id = str(uuid.uuid1())
        for row in csv_reader:
            total_price += float(row["unit_price"]) * float(row["quantity"])
            item_table.put_item(
                Item={
                    'id': str(uuid.uuid1()),
                    'command_id': command_id,
                    'item_name': row["item_name"],
                    'unit_price': row["unit_price"],
                    'quantity': row["quantity"],
                    'customer': row["customer"],
                    'salesman': row["salesman"]
                }
            )
        command_table.put_item(
            Item={
                'id': command_id,
                'date': str(datetime.now()),
                'status': "Pending"
            }
        )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "image saved to s3://" + BUCKET_NAME + "/",
        }),
    }
