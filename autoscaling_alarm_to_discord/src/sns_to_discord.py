import boto3
import json
import logging
import os

from base64 import b64decode
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

HOOK_URL = os.environ['HOOK_URL']

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("Event: " + str(event))
    message = json.loads(event['Records'][0]['Sns']['Message'])
    logger.info("Message: " + str(message))
    
    discord_message = {
        'username': 'CloudWatch Monitor',
        'avatar_url': 'https://i.imgur.com/4M34hi2.png',
        'content': 'Test'
    }
    
    if 'AlarmName' in message:
        discord_message = {
            'username': 'CloudWatch Monitor',
            'avatar_url': 'https://i.imgur.com/4M34hi2.png',
            'content': "AlarmName: %s \n OldStateValue: %s \n NewStateValue: %s " % (message['AlarmName'], message['OldStateValue'], message['NewStateValue'])
        }
    
    if 'Origin' in message:
        discord_message = {
            'username': 'CloudWatch Monitor',
            'avatar_url': 'https://i.imgur.com/4M34hi2.png',
            'content': "Origin: %s \n Cause: %s \n Event: %s " % (message['Origin'], message['Cause'], message['Event'])
        }
    

    payload = json.dumps(discord_message).encode('utf-8')
    headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Content-Length': len(payload),
        'Host': 'discord.com',
        'user-agent': 'Mozilla/5.0'
    }
    req = Request(HOOK_URL, payload, headers)
    
    try:
        response = urlopen(req)
        response.read()
        logger.info("Message posted to discord")
    except HTTPError as e:
        logger.error("Request failed: %d %s", e.code, e.reason)
        logger.error(e.read())
    except URLError as e:
        logger.error("Server connection failed: %s", e.reason)
