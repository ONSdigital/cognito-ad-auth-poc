import logging
from pprint import pformat

def _get_logger(name):
    handler = logging.StreamHandler()
    handler.setLevel(logging.INFO)
    logger = logging.getLogger(name)
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger

def handler(event, context):
    logger = _get_logger(__name__)
    logger.info(f"EVENT:\n{pformat(event)}")
    logger.info(f"CONTEXT:\n{pformat(context)}")
    return {
        "statusCode": 200,
        "statusDescription": "200 OK",
        "isBase64Encoded": False,
        "headers": {
            "Content-Type": "text/html"
        },
        "body": "<h1>Cognito Login Test OK</h1>"
    }