""" 
Module to get the private key from GCP secrets manager 

"""

from google.cloud import secretmanager

def get_private_key(project_id: str, secret_id: str):
    # Create the Secret Manager client
    client = secretmanager.SecretManagerServiceClient()
    name = client.secret_version_path(project_id, secret_id, 'latest')

    # Getting private key
    private_key = client.access_secret_version(request={'name': name}).payload.data.decode('UTF-8')
    return private_key