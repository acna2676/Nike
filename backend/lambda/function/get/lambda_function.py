import json
import datetime
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('atum')


def get_item(path_parameters):
    user_id = path_parameters.get('user_id')

    if not user_id:
        return 400

    try:
        response = table.query(
            KeyConditionExpression=Key('pk').eq('id_' + user_id) & Key('sk').begins_with('task_')
        )
    except Exception as e:
        return 500

    items = response['Items']  # [0]

    services = []
    for item in items:
        services.append({'task_name': item.get('sk')[5:], 'expiration_date': item.get('expiration_date')})

    body = {
        "services": services
    }

    return 200, body


def lambda_main(path_parameters):

    status_code, body = get_item(path_parameters)

    return status_code, body


def handler(event, context):
    status_code = 200
    input_path_parameters = event.get('pathParameters')

    if not input_path_parameters:
        status_code = 400

    status_code, body = lambda_main(input_path_parameters)

    return {'statusCode': status_code,
            'body': json.dumps(body),
            'headers': {
                'Content-Type': 'application/json'
            }}
