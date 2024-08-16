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


def create_or_edit_note(event, context):
    """Sample pure Lambda function

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    ------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    """
    
    # 1. Get the cognito user id
    try:
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        body = json.loads(event['body'])
        if 'id' not in body:
            return {
                "statusCode": 400,
                'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'
                        },
                "body": json.dumps({
                    "message": "Note id not found! Bad Request!",
                }),
            }
        
        note_id = body['id'] # this has to exist

        table.put_item(
            Item={
                'userId': cognito_user_id,
                'noteId': note_id,
                'title': body['title'],
                'content': body['content'],
                'createdAt': body['createdAt'],
                'updatedAt': body['updatedAt'],
                'imageKeys': body['imageKeys'],
            },
            ReturnValues='NONE'
        )
    except Exception as e:
        print(e)
        return {
            "statusCode": 400,
            "body": json.dumps({
                'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'
                        },
                "message": "WEIRD ERROR HAPPENED -- " + str(event),
            }),
        }
    return {
                "statusCode": 200,
                "body": json.dumps({
                    'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'
                        },
                    "message": "CREATED!",
                    "updated":json.dumps(body, cls=DecimalEncoder)
                }),
            }

# def update_note(event, context):
#     """Sample pure Lambda function

#     Parameters
#     ----------
#     event: dict, required
#         API Gateway Lambda Proxy Input Format

#         Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

#     context: object, required
#         Lambda Context runtime methods and attributes

#         Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

#     Returns
#     ------
#     API Gateway Lambda Proxy Output Format: dict

#         Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
#     """    
#     # 1. Get the cognito user id
#     try:
#         cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
#         body = json.loads(event['body'])
#         note_id = body['id']
#         # check if the note exists and if it does not return an error
#         response = table.get_item(
#             Key={
#                 'userId': cognito_user_id,
#                 'noteId': note_id
#             }
#         )
#         if 'Item' not in response:
#             return {
#                 "statusCode": 400,
#                 "body": json.dumps({
#                     'headers': {
#                             'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
#                             'Access-Control-Allow-Origin': '*',
#                             'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'
#                         },
#                     "message": "Note not found",
#                 }),
#             }
            
#         table.put_item(
#             Item={
#                 'userId': cognito_user_id,
#                 'noteId': body['id'],
#                 'title': body['title'],
#                 'content': body['content'],
#                 'createdAt': body['createdAt'],
#                 'updatedAt': body['updatedAt'],
#                 'imageKeys': body['imageKeys'],
#             },
#             ReturnValues='NONE'
#         )
#     except Exception as e:
#         print(e)
#         return {
#             "statusCode": 400,
#             'headers': {
#                             'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
#                             'Access-Control-Allow-Origin': '*',
#                             'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'
#                         },
#             "body": json.dumps({
#                 "message": "WEIRD ERROR HAPPENED -- " + str(event), # this shouldn't happen
#             }),
#         }
#     return {
#                 "statusCode": 200,
#                 'headers': {
#                             'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
#                             'Access-Control-Allow-Origin': '*',
#                             'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'
#                         },
#                 "body": json.dumps({
#                     "message": "UPDATED!",
#                     "updated":json.dumps(body, cls=DecimalEncoder)
#                 }),
#             }


def delete_note(event, context):
    """Sample pure Lambda function

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    ------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    """
    # 1. Get the cognito user id
    try:
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        body = json.loads(event['body'])
        note_id = body['id']
        # check if the note exists and if it does not return an error
        response = table.get_item(
            Key={
                'userId': cognito_user_id,
                'noteId': note_id
            }
        )
        if 'Item' not in response:
            return {
                'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT,DELETE'
                        },
                "statusCode": 200, # this is the case when the note is already deleted
                "body": json.dumps({
                    "message": "Already deleted!",
                }),
            }
        table.delete_item(
            Key={
                'userId': cognito_user_id,
                'noteId': note_id
            },
            ReturnValues='NONE'
        )
    except Exception as e:
        print(e)
        return {
            'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT,DELETE'
                        },
            "statusCode": 400,
            "body": json.dumps({
                "message": "WEIRD ERROR HAPPENED -- " + str(event), # this shouldn't happen
            }),
        }
    return {
                "statusCode": 200,
                'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT,DELETE'
                        },
                "body": json.dumps({
                    "message": "DELETED!",
                }),
            }

def get_notes(event, context):
    """Sample pure Lambda function

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    ------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    """
    # 1. Get the cognito user id
    try:
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        response = table.query(
            KeyConditionExpression='userId = :userId',
            ExpressionAttributeValues={
                ':userId': cognito_user_id
            }
        )
        items = response['Items']
        # change noteId to id
        for item in items:
            item['id'] = item['noteId']
            del item['noteId']
    except Exception as e:
        print(e)
        return {
            "statusCode": 400,
            'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
            "body": json.dumps({
                "message": "WEIRD ERROR HAPPENED -- " + str(event), # this shouldn't happen
            }),
        }
    return {
                "statusCode": 200,
                'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'
                        },
                "body": json.dumps({
                    "message": "GOT NOTES!",
                    "notes": json.dumps(items, cls=DecimalEncoder)
                }),
            }