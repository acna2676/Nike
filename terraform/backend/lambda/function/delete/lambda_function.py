import datetime
import json

import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('nike-dev')


def put_items(add_items, path_parameters):

    user_id = path_parameters.get('user_id')
    for item in add_items:
        task_name = item.get('task_name')
        # expiration_date = item.get('expiration_date')

        if not all([user_id, task_name]):  # , expiration_date]):
            return 500

        items = {
            "HK": 'id_' + user_id,
            "Rk": 'task_' + task_name,
        }
        # "expiration_date": expiration_date

        try:
            table.put_item(
                Item=items
            )
        except Exception as e:
            print(e)
            return 500

    return 200


def f_delete_items(path_parameters):
    user_id = path_parameters.get('user_id')
    task_id = path_parameters.get('task_id')
    # for item in delete_items:
    # task_name = item.get('task_name')

    if not all([user_id, task_id]):
        return 500

    keys = {
        "HK": 'id_' + user_id,
        "RK": task_id,
    }

    try:
        table.delete_item(
            Key=keys
        )
    except Exception as e:
        print(e)
        return 500

    return 200


def update_item(path_parameters):
    # print(add_items, delete_items)

    # status_code_put = put_items(add_items, path_parameters)
    status_code_delete = f_delete_items(path_parameters)

    # if all([status_code_put, status_code_delete]):
    #     return 200

    return 500


def lambda_main(path_parameters):

    status_code = update_item(path_parameters)

    return status_code


def handler(event, context):
    status_code = 200
    message = 'Success'

    # input_body_json = event.get('body')
    input_path_parameters = event.get('pathParameters')

    # if not input_body_json:
    #     status_code = 500

    # input_body = json.loads(input_body_json)
    status_code = lambda_main(input_path_parameters)

    body = {
        'message': message,
    }

    return {'statusCode': status_code,
            'body': json.dumps(body),
            'headers': {'Content-Type': 'application/json'}}
