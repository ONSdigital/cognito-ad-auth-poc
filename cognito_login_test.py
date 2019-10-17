import logging
from flask import (
    Flask,
    jsonify
)
from pprint import pformat

import awsgi

app = Flask(__name__)

def _get_logger(name):
    handler = logging.StreamHandler()
    handler.setLevel(logging.INFO)
    logger = logging.getLogger(name)
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger


@app.route('/')
def index():
    return (
        "<h1>Cognito Flask app HELO</h1>",
        200
    )

def lambda_handler(event, context):
    logger = _get_logger(__name__)

    response = awsgi.response(app, event, context)
    logger.info(f"TYPE: {pformat(type(response))}")
    logger.info(f"RESPONSE: {pformat(response)} ")
    return response
