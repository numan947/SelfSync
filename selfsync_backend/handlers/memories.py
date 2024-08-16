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


def create_or_update_memories(event, context):
    try:
        # 1. Get the cognito user id
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        body = json.loads(event['body'])
        
        if 'id' not in body or 'title' not in body or 'imageKeys' not in body:
            return {
            'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
                "statusCode": 400,
                "body": json.dumps({
                    "message": "Memories id, title, imageKeys not found! Bad Request!",
                }),
            }
        # conver the imageKeys to a map
        kk = body['imageKeys']
        imageKeys = list(kk.keys()) # this should be an empty map if no images
        ItemMap = {
            'userId': cognito_user_id,
            'memoriesId': body['id'],
            'title': body['title'],
            'imageKeys': imageKeys, # this should be an empty map if no images
        }
        if 'startDate' in body:
            ItemMap['startDate'] = body['startDate']
        if 'endDate' in body:
            ItemMap['endDate'] = body['endDate']
        if 'description' in body:
            ItemMap['description'] = body['description']
        
        table.put_item(
            Item=ItemMap,
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



def get_memories(event, context):
    try:
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        response = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('userId').eq(cognito_user_id)
        )
        for item in response['Items']:
            item['id'] = item['memoriesId']
        #convert he imageKeys to a map for the frontend
        for item in response['Items']:
            kk = item['imageKeys']
            item['imageKeys'] = {key: '' for key in kk}
        return {
                        'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
            "statusCode": 200,
            "body": json.dumps({
                "message": "GETTING ALL MEMORIES!",
                "memories": json.dumps(response['Items'], cls=DecimalEncoder)
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




def delete_memories(event, context):
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
                    "message": "Memories id not found! Bad Request!",
                }),
            }
        
        memories_id = body['id'] # this has to exist
        
        response = table.get_item(
            Key={
                'userId': cognito_user_id,
                'memoriesId': memories_id
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
                'memoriesId': memories_id
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