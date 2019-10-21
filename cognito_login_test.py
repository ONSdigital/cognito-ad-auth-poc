import logging
import os
import flask
from flask_dance.consumer import OAuth2ConsumerBlueprint
from pprint import pformat

import awsgi

app = flask.Flask(__name__)
app.secret_key = os.getenv('flask_secret_key')

cognito_blueprint = OAuth2ConsumerBlueprint(
    "cognito", __name__,
    client_id=os.environ.get("oauth_client_id"),
    client_secret=os.environ.get("oauth_client_secret"),
    base_url=os.environ.get("oauth_base_url"),
    token_url=os.environ.get("oauth_token_url"),
    authorization_url=os.environ.get("oauth_auth_url"),
)
app.register_blueprint(cognito_blueprint, url_prefix="/login")

def _get_logger(name):
    handler = logging.StreamHandler()
    handler.setLevel(logging.INFO)
    logger = logging.getLogger(name)
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger


@app.route('/')
def index():
    if not cognito_blueprint.session.authorized:
        output = flask.render_template_string(
            """
                <html>
                <head><title>SSO Test site</title></head>
                <body>
                <p>Please <a href="{{login_url}}">Login</a></p>
                </body>
                </html>
            """,
            login_url=flask.url_for("cognito.login")
        )
    else:
        output = flask.render_template_string("""
            <html>
            <head><title>SSO Test site</title></head>
            <body>
            You are logged in.
            </body>
            </html>
        """)
    return (
        output,
        200
    )

def lambda_handler(event, context):
    logger = _get_logger(__name__)

    return awsgi.response(app, event, context)
    logger.info(f"TYPE: {pformat(type(response))}")
    logger.info(f"RESPONSE: {pformat(response)} ")
    return response
