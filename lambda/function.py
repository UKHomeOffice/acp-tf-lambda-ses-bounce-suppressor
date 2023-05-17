import boto3
import json
import os
import sys
import logging
from botocore.exceptions import ClientError
from datetime import datetime, timedelta

# try setting dynamo table name from env var:
try:
    DYNAMO_TABLE = os.environ['DYNAMO_TABLE']
except Exception as e:
    DYNAMO_TABLE = None

# try setting ttl (days) for dynamo entries - defaults to 14 days
try:
    DYNAMO_TTL_DAYS = os.environ['DYNAMO_TTL_DAYS']
except Exception as e:
    DYNAMO_TTL_DAYS = '14'

# create needed clients
sesv2 = boto3.client('sesv2')
dynamodb = boto3.client('dynamodb')

# Add logging output for cloudwatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# expected SES notifications
notification_type_recipients_dict = {
    'Bounce': 'bouncedRecipients',
    'Complaint': 'complainedRecipients'
}

# Method to check if a given email is already suppressed
def check_suppressed (dest_email):
    response = {}
    try:
        logger.info('STEP :: check if recipient is already suppressed')
        response = sesv2.get_suppressed_destination(EmailAddress=dest_email)
    except ClientError as e:
        if e.response['Error']['Code'] == 'NotFoundException':
            logger.info('RESULT :: recipient is not currently suppressed at account level')
            return False
        else:
            logger.error('ERROR :: issue trying to process recipient email address')
            raise e

    if response:
        logger.error('RESULT :: recipient is already suppressed at account level')
        return True
    else:
        logger.error('RESULT :: assume recipient is already suppressed at account level')
        return False

# Method to return message - two different ways
def return_ses_msg (record):
    msg_body = json.loads(record['body'])
    msg = {}

    logger.info('STEP :: attempt to load message from SQS')

    if 'Message' in msg_body:
        logger.info('INFO :: msg encapsulation detected')
        msg = json.loads(msg_body['Message'])
    else:
        logger.info('INFO :: no msg encapsulation detected')
        msg = msg_body

    return msg

# Method to add to dynamodb for analytic purposes
def add_dynamo_record (request_id, source_email, recipient_email, ses_identity):
    if DYNAMO_TABLE:
        logger.info('STEP :: dynamo table defined')

        current_date = datetime.now()
        ttl_date = (current_date + timedelta(days=int(DYNAMO_TTL_DAYS))).timestamp()

        item = {
            "uuid": {"S": request_id},
            "source_email": {"S": source_email},
            "recipient_email": {"S": recipient_email},
            "ses_identity": {"S": str(ses_identity)},
            "date_stamp": {"S": str(current_date)},
            "ttl": {"N": str(ttl_date)}
        }

        try:
            logger.info('STEP :: attempt to add info to dynamo')
            dynamodb.put_item(TableName=DYNAMO_TABLE, Item=item)
            logger.info('STEP :: info added to dynamo')
        except Exception as e:
            logger.error('ERROR :: unable to add info to dynamo')
            print (e)
    else:
        logger.info('SKIP :: no dynamo table defined')

#AWS seems to have two different formats returned by bounce notifications, adding both
def lambda_handler(event, context):

    logger.info('START :: check and supress recipients that have bounced or complained')

    for record in event['Records']:
        ses_msg = return_ses_msg(record)
        notification_type = ses_msg['notificationType']

        if notification_type not in ['Bounce', 'Complaint']:
            logger.info('SKIP :: {} is not a notification from SES'.format(notification_type))
            return {
                'statusCode': 200,
                'body': 'SKIP :: {} - is not a notification from SES'.format(notification_type)
            }

        for recipient in ses_msg[notification_type.lower()][notification_type_recipients_dict[notification_type]]:
            logger.info('STEP :: check recipient from source email ({})'.format(ses_msg['mail']['source']))

            if recipient['emailAddress'] == 'bounce@simulator.amazonses.com':
                logger.info('SKIP :: recipient is test email (bounce@simulator.amazonses.com)')
                continue

            if check_suppressed(recipient['emailAddress']):
                continue
            
            logger.info('STEP :: put recipient on account level suppression list from source email ({})'.format(ses_msg['mail']['source']))

            try:
                put_suppressed_res = sesv2.put_suppressed_destination(
                    EmailAddress=recipient['emailAddress'],
                    Reason=notification_type.upper()
                )
            except ClientError as e:
                if "sandbox" in e.response['Error']['Message']:
                    logger.info('SKIP :: account is still in sandbox mode')
                else:
                    raise e
            
            # Attempt to add bounced email to dynamo table for limited future analyics
            add_dynamo_record(context.aws_request_id, ses_msg['mail']['source'], recipient['emailAddress'], ses_msg['mail']['sourceArn'].split('/')[-1])
                    
            logger.info('RESULT :: recipient from source email ({}) has been put recipient on account level suppression list with reason - {}'.format(ses_msg['mail']['source'], notification_type.upper()))

    logger.info('END :: bounced and complaints from recipients have been processed')
    return {
        'statusCode': 200,
        'body': 'END :: SES automatic suppression finished'
    }
