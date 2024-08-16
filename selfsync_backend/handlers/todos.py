import json
import uuid
import boto3
import requests
import os
import time
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
  def default(self, obj):
    if isinstance(obj, Decimal):
      return str(obj)
    return json.JSONEncoder.default(self, obj)


## TODO: NEED TO ADD LENGTH VALIDATION FOR TITLE AND CONTENT

table_name = os.environ['TABLE_NAME']
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)


def create_or_update_todo(event, context):
    try:
        # 1. Get the cognito user id
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        body = json.loads(event['body'])
        
        if 'id' not in body or 'title' not in body or 'dateAdded' not in body or 'dueDate' not in body or 'completed' not in body:
            return {
            'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
                "statusCode": 400,
                "body": json.dumps({
                    "message": "Todo id, title, content, dateAdded, dueDate, completed not found! Bad Request!",
                }),
            }
            
        table.put_item(
            Item={
                'userId': cognito_user_id,
                'todoId': body['id'],
                'title': body['title'],
                'dateAdded': body['dateAdded'],
                'dueDate': body['dueDate'],
                'completed': body['completed'],
            },
            ReturnValues='NONE'
        )
    except Exception as e:
        print(e)
        return {
                        'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
            "statusCode": 400,
            "body": json.dumps({
                "message": "WEIRD ERROR HAPPENED -- " + str(event),
            }),
        }
    return {
                    'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
                "statusCode": 200,
                "body": json.dumps({
                    "message": "Create or Update!",
                    "updated":json.dumps(body, cls=DecimalEncoder)
                }),
            }



def get_todos(event, context):
    try:
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        response = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('userId').eq(cognito_user_id)
        )
        for item in response['Items']:
            item['id'] = item['todoId']
        return {
                        'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
            "statusCode": 200,
            "body": json.dumps({
                "message": "GETTING ALL TODOS",
                "todos": json.dumps(response['Items'], cls=DecimalEncoder)
            }),
        }
    except Exception as e:
        print(e)
        return {
                        'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
            "statusCode": 400,
            "body": json.dumps({
                "message": "WEIRD ERROR HAPPENED -- " + str(event),
            }),
        }




def delete_todo(event, context):
    try:
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        body = json.loads(event['body'])
        if 'id' not in body:
            return {
                            'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
                "statusCode": 400,
                "body": json.dumps({
                    "message": "Todo id not found! Bad Request!",
                }),
            }
        
        todo_id = body['id'] # this has to exist
        
        response = table.get_item(
            Key={
                'userId': cognito_user_id,
                'todoId': todo_id
            }
        )
        if 'Item' not in response:
            return {
                            'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
                "statusCode": 200,
                "body": json.dumps({
                    "message": "Already Deleted!",
                }),
            }
        
        table.delete_item(
            Key={
                'userId': cognito_user_id,
                'todoId': todo_id
            }
        )
    except Exception as e:
        print(e)
        return {
                        'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
            "statusCode": 400,
            "body": json.dumps({
                "message": "WEIRD ERROR HAPPENED -- " + str(event),
            }),
        }
    return {
                "statusCode": 200,
                "body": json.dumps({
                    "message": "DELETED!",
                }),
            }