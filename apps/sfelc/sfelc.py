from utils.sflc_logger import sflc_logger
import os
import sys
from utils.sflc_fileops import (
    get_latest_log_file_url,
    convert_csv_file_to_json_files,
    upload_to_storage_bucket,
)
from utils.sflc_logger import sflc_logger
from utils.sflc_secret import get_private_key
from utils.sflc_session import create_tls_session

# Retrieve enviromental variables
SECRET_NAME = os.environ.get("SECRET_NAME")
SECRET_ID = os.environ.get("SECRET_ID")
CLIENT_ID = os.environ.get("CLIENT_ID")
AUDIENCE = os.environ.get("AUDIENCE")
TOKEN_ENDPOINT = os.environ.get("TOKEN_ENDPOINT")
SUBJECT = os.environ.get("SUBJECT")
CLOUD_STORAGE_BUCKET = os.environ.get("CLOUD_STORAGE_BUCKET")
GOOGLE_PROJECT_ID = os.environ.get("GOOGLE_PROJECT_ID")
GOOGLE_SECRETS_PROJECT_ID = os.environ.get("GOOGLE_SECRETS_PROJECT_ID")
EVENT_TYPES = os.environ.get("EVENT_TYPES")


# Event type log retrieval frequency
TIME_INTERVAL = "Hourly"


def get_event_log_files(
    token_endpoint: str,
    private_key: str,
    client_id: str,
    audience: str,
    subject: str,
    event_types: list,
    time_interval: str,
    google_project_id: str,
    cloud_storage_bucket: str,
) -> None:
    """Retrieves event type log files from salesforce and uploads them cloud to storage"""

    # Setup TLS session to salesforce instance url
    tls_session = create_tls_session(
        token_endpoint, private_key, client_id, audience, subject
    )

    # Get event log files from salesforce
    for event in event_types:
        event_log_file_object = tls_session.get(
            f"/services/data/v58.0/query?q=SELECT+Id+,+EventType+,+Interval+,+LogDate+,+LogFile+FROM+EventLogFile+WHERE+EventType+=+'{event}'+AND+Interval+=+'{time_interval}'"
        )
        event_log_file_record = event_log_file_object.json()

        if event_log_file_record["totalSize"] == 0:
            sflc_logger.info(f"Log files not found for the {event} event type")
        else:
            # Get the latest log file generated for the event type
            latest_file_url = get_latest_log_file_url(event_log_file_record)

            # Download CSV Log file
            downloaded_csv_file = tls_session.get(latest_file_url)

            # Convert csv file to json
            convert_csv_file_to_json_files(f"{event}", downloaded_csv_file.content)

    # Upload to GCP storage
    upload_to_storage_bucket(google_project_id, cloud_storage_bucket)

    # Log to GCP Cloud Logging
    sflc_logger.info(f"Completed Log file upload to Storage Bucket")


# Get Private Key
private_key = get_private_key(GOOGLE_SECRETS_PROJECT_ID, SECRET_ID)

# Get Event Types as a List object
event_types = EVENT_TYPES.split(", ")

# Start script
if __name__ == "__main__":
    try:
        get_event_log_files(
            TOKEN_ENDPOINT,
            private_key,
            CLIENT_ID,
            AUDIENCE,
            SUBJECT,
            event_types,
            TIME_INTERVAL,
            GOOGLE_PROJECT_ID,
            CLOUD_STORAGE_BUCKET,
        )

    except Exception as err:
        sflc_logger.exception(f"An Error occured")
        sys.exit(1)
