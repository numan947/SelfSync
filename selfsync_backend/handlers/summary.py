import json
import uuid
import boto3
from boto3.dynamodb.conditions import Key
from boto3.dynamodb.conditions import Attr
import requests
import math
import os
import time
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
  def default(self, obj):
    if isinstance(obj, Decimal):
      return str(obj)
    return json.JSONEncoder.default(self, obj)

dynamodb = boto3.resource('dynamodb')

budget_table = os.environ['BUDGET_TABLE']
budgetTable = dynamodb.Table(budget_table)

memories_table = os.environ['MEMORIES_TABLE']
memoriesTable = dynamodb.Table(memories_table)

notes_table = os.environ['NOTES_TABLE']
notesTable = dynamodb.Table(notes_table)

todos_table = os.environ['TODOS_TABLE']
todosTable = dynamodb.Table(todos_table)

def get_summary(event, context):
    # Get the user_id from the request
    user_id = event['requestContext']['authorizer']['claims']['sub']

    # Get the budget summary
    currentYear = time.strftime("%Y")
    currentMonth = time.strftime("%m")
    currentMonth = str(int(currentMonth))
    
    ## Create Yearly Budget Summary, total cost
    
    response = budgetTable.query(
        KeyConditionExpression = Key('userId').eq(user_id),
        FilterExpression=Attr('dateYear').eq(currentYear)
    )
    yearlyBudgetSummary = response['Items']
    yearlyBudgetTotal = 0
    for item in yearlyBudgetSummary:
        yearlyBudgetTotal += item['amount']
    # roundup to nearest integer
    yearlyBudgetTotal = Decimal(math.ceil(yearlyBudgetTotal))
    yearlyBudgetTotal = Decimal(yearlyBudgetTotal)
    
    ## Create Monthly Budget Summary, total cost
    response = budgetTable.query(
        KeyConditionExpression = Key('userId').eq(user_id),
        FilterExpression=Attr('dateYear').eq(currentYear) & Attr('dateMonth').eq(currentMonth)
    )
    monthlyBudgetSummary = response['Items']
    monthlyBudgetTotal = 0
    for item in monthlyBudgetSummary:
        monthlyBudgetTotal += item['amount']
    # roundup to nearest integer
    monthlyBudgetTotal = Decimal(math.ceil(monthlyBudgetTotal))
    monthlyBudgetTotal = Decimal(monthlyBudgetTotal)
    
    
    ## Create Memories Summary, count, count of total photos
    response = memoriesTable.query(
        KeyConditionExpression = Key('userId').eq(user_id)
    )
    memoriesSummary = response['Items']
    memoriesCount = len(memoriesSummary)
    memoriesPhotoCount = 0
    for item in memoriesSummary:
        memoriesPhotoCount += len(item['imageKeys'])
    memoriesPhotoCount = Decimal(memoriesPhotoCount)
    memoriesCount = Decimal(memoriesCount)
    
    ## Create Notes Summary, count
    response = notesTable.query(
        KeyConditionExpression = Key('userId').eq(user_id)
    )
    notesSummary = response['Items']
    notesCount = len(notesSummary)
    notesCount = Decimal(notesCount)
    notesImageCount = 0
    for item in notesSummary:
        notesImageCount += len(item['imageKeys'])
    notesImageCount = Decimal(notesImageCount)
    
    ## Create Todos Summary, count
    response = todosTable.query(
        KeyConditionExpression = Key('userId').eq(user_id)
    )
    todosSummary = response['Items']
    todosCount = len(todosSummary)
    todosCount = Decimal(todosCount)
    completedTodosCount = 0
    for item in todosSummary:
        if item['completed']:
            completedTodosCount += 1
    completedTodosCount = Decimal(completedTodosCount)
    
    ## Create Summary
    
    summary = {
        'yearlyCost': yearlyBudgetTotal,
        'monthlyCost': monthlyBudgetTotal,
        'totalMemories': memoriesCount,
        'totalMemoryImages': memoriesPhotoCount,
        'noteCount': notesCount,
        'totalImagesInNotes': notesImageCount,
        'todoCount': todosCount,
        'completedTodoCount': completedTodosCount
    }
    return {
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Amz-Security-Token,Authorization,X-Api-Key,X-Requested-With,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers,X-Amz-User-Agent',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
        },
        "statusCode": 200,
        "body": json.dumps({
            "message": "Summary",
            "summary": json.dumps(summary, cls=DecimalEncoder)
        }),
    }

