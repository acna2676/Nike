import json
import uuid

import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('nike-dev')


def put_items(task, path_parameters):

    # user_id = path_parameters.get('user_id')
    user_id = "acna2676"  # FIXME: test
    # for item in add_items:
    task_name = task.get('task')
    # expiration_date = item.get('expiration_date')

    if not all([user_id, task_name]):  # , expiration_date]):
        return 500
    task_id = str(uuid.uuid4())
    items = {
        "HK": 'id_' + user_id,
        "RK": task_id,
        "Task": 'task_' + task_name
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


def f_delete_items(delete_items, path_parameters):
    user_id = path_parameters.get('user_id')
    for item in delete_items:
        task_name = item.get('task_name')

        if not all([user_id, task_name]):
            return 500

        keys = {
            "pk": 'id_' + user_id,
            "sk": 'task_' + task_name,
        }

        try:
            table.delete_item(
                Key=keys
            )
        except Exception as e:
            print(e)
            return 500

    return 200


def update_item(body, path_parameters):
    # add_items = body.get('add_items')
    # delete_items = body.get('delete_items')
    # print(add_items, delete_items)

    status_code_put = put_items(body, path_parameters)
    # status_code_delete = f_delete_items(delete_items, path_parameters)

    # if all([status_code_put, status_code_delete]):
    #     return 200

    return 500


def lambda_main(body, path_parameters):
    print("body = ", body)

    status_code = update_item(body, path_parameters)

    return status_code


def handler(event, context):
    status_code = 200
    message = 'Success'

    input_body_json = event.get('body')
    input_path_parameters = event.get('pathParameters')

    if not input_body_json:
        status_code = 500

    print(input_body_json)
    input_body = json.loads(input_body_json)
    status_code = lambda_main(input_body, input_path_parameters)

    body = {
        'message': message,
    }

    return {'statusCode': status_code,
            'body': json.dumps(body),
            'headers': {'Content-Type': 'application/json'}}
