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


def create_or_update_budget(event, context):
    try:
        # 1. Get the cognito user id
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        body = json.loads(event['body'])
        
        if 'id' not in body or 'entryTitle' not in body or 'amount' not in body or 'dateDay' not in body or 'dateMonth' not in body or 'dateYear' not in body:
            return {
            'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
                "statusCode": 400,
                "body": json.dumps({
                    "message": "Bad Request!",
                }),
            }
            
        ItemMap = {
            'userId': cognito_user_id,
            'budgetId': body['id'],
            'entryTitle': body['entryTitle'],
            'amount': Decimal(body['amount']),
            'dateDay': body['dateDay'],
            'dateMonth': body['dateMonth'],
            'dateYear': body['dateYear'],
        }        
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



def get_budget(event, context):
    try:
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        query_params = event['queryStringParameters']
        year = query_params['year']
        month = query_params['month']
        ## if month == 0, then get all the budgets for the year, dynamically adjust the query
        if int(month) == 0:
            response = table.query(
                KeyConditionExpression=boto3.dynamodb.conditions.Key('userId').eq(cognito_user_id),
                FilterExpression=boto3.dynamodb.conditions.Attr('dateYear').eq(year)
            )
        else:
            response = table.query(
                KeyConditionExpression=boto3.dynamodb.conditions.Key('userId').eq(cognito_user_id),
                FilterExpression=boto3.dynamodb.conditions.Attr('dateYear').eq(year) & boto3.dynamodb.conditions.Attr('dateMonth').eq(month)
            )
        
        for item in response['Items']:
            item['id'] = item['budgetId']
        return {
                        'headers': {
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
                        },
            "statusCode": 200,
            "body": json.dumps({
                "message": "GETTING ALL budget!",
                "budget": json.dumps(response['Items'], cls=DecimalEncoder)
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




def delete_budget(event, context):
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
                    "message": "budget id not found! Bad Request!",
                }),
            }
        
        budget_id = body['id'] # this has to exist
        
        response = table.get_item(
            Key={
                'userId': cognito_user_id,
                'budgetId': budget_id
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
                'budgetId': budget_id
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