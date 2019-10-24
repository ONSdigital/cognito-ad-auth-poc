import logging
import os
import flask
from flask_dance.consumer import (
    oauth_authorized,
    OAuth2ConsumerBlueprint
)
from pprint import pformat
from urllib.parse import (urlencode, urljoin)
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
    scope="openid profile email"
)
app.register_blueprint(cognito_blueprint, url_prefix="/login")


@oauth_authorized.connect
def fetch_user_info(blueprint, token):
    response = blueprint.session.get(os.environ.get("user_profile_url"))
    if not response.ok:
        app.logger.warn(
            f"Error retrieving user profile: {response.status_code}"
            f" {response.content}"
        )
        return flask.Response(status=500)
    flask.session['user_id'] = response.json()['sub']

@app.route('/logout')
def logout():
    flask.session.pop('cognito_oauth_token', None)
    return flask.redirect('/')

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
            login_url=flask.url_for("cognito.login"),
            session_contents=pformat(flask.session)
        )
    else:
        logout_link = urljoin(
            os.environ.get("oauth_base_url"),
            "logout"
        )
        logout_link += "?" + urlencode({
            "client_id": os.environ.get("oauth_client_id"),
            "logout_uri": urljoin(
                os.environ.get("redirect_url"),
                'logout'
            )
        })
        output = flask.render_template_string(
            """
            <html>
            <head><title>SSO Test site</title></head>
            <body>
            <p>You are logged in as {{user_id}}</p>
            <p><a href="{{logout_url}}">Logout</a></p>
            </body>
            </html>
            """,
            logout_url=logout_link,
            user_id=flask.session['user_id']
        )
    return (
        output,
        200
    )

def lambda_handler(event, context):
    return awsgi.response(app, event, context)
