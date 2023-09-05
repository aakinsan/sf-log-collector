""" 
Module to build the TLS session to Salesforce and optimize network connection

"""

import jwt
import requests
from requests_toolbelt import sessions
from datetime import datetime, timedelta
from .sflc_logger import sflc_logger
from requests.adapters import HTTPAdapter
from requests.exceptions import HTTPError
from urllib3.util import Retry


class SflcHTTPAdapter(HTTPAdapter):
    def __init__(self, *args, **kwargs):
        self.timeout = kwargs.pop('timeout')
        super().__init__(*args, **kwargs)
    
    def send(self, request, **kwargs):
        kwargs["timeout"] = self.timeout			
        return super().send(request, **kwargs)

retry_strategy = Retry(total=3,
                       status_forcelist=[500, 502, 503, 504],
                       allowed_methods=frozenset({'POST', 'DELETE', 'GET', 'HEAD', 'OPTIONS', 'PUT', 'TRACE'}),
                       backoff_factor=5,                       
                       )

# Create adapter with timeout value and retry strategy
sflc_adapter = SflcHTTPAdapter(timeout=5, max_retries=retry_strategy)


def create_tls_session(token_endpoint: str, private_key: str, client_id: str, audience: str, subject: str) -> None:
    # Authenticates to the Salesforce token endpoint API using the Oauth2.0 JWT Bearer
    # Gets an access token after successful authentication and creates session object

    # Build JWT Payload
    now = datetime.now()
    expiration_time = (now + timedelta(minutes=60)).timestamp()
    private_key = private_key.encode("utf-8")

    payload = {
        "iss": client_id,
        "sub": subject,
        "aud": audience,
        "exp": expiration_time,
    }

    signed_jwt = jwt.encode(payload, private_key, algorithm="RS256")
    
    data = {
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": signed_jwt,
    }
    headers = {"Content-Type": "application/x-www-form-urlencoded"}

    # Create session object
    tls_session = requests.Session()

    # Mount sflc transport adapter (with timeout and retry configs) to session object
    tls_session.mount('https://', sflc_adapter)

    # Send Request to Salesforce Token Endpoint URL            
    response = tls_session.post(token_endpoint, data=data, headers=headers)

    # Raise Exception if status code returned is a 4xx; 5xx Errors are handled by HTTP Transport Adapter
    if response.status_code in range(400, 500):
        raise HTTPError
    
    # Get access token and salesforce instance url
    response_body = response.json()
    access_token = response_body.get("access_token")
    instance_url = response_body.get("instance_url")

    # Setting base URL for session object
    tls_session = sessions.BaseUrlSession(base_url=instance_url)

    # Setting Authorization bearer for session object
    tls_session.headers.update({"Authorization":"Bearer " + access_token})

    # Return session object
    return tls_session