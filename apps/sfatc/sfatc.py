from utils.sflc_logger import sflc_logger
import os
import sys
from utils.sflc_fileops import (
    convert_audit_to_json,
    convert_audit_trail_to_json_files,
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

# Event type log retrieval frequency
created_date = "YESTERDAY"


def get_sf_audit_trails(
    token_endpoint: str,
    private_key: str,
    client_id: str,
    audience: str,
    subject: str,
    created_date: str,
    google_project_id: str,
    storage_bucket: str,
) -> None:
    """Collects Audit trails and uploads to GCP storage"""

    # Setup TLS session to salesforce instance url
    tls_session = create_tls_session(
        token_endpoint, private_key, client_id, audience, subject
    )

    # Get audit trail object from salesforce
    audit_trail_object = tls_session.get(
        f"/services/data/v58.0/query?q=SELECT+Action+,+CreatedBy.Name+,+CreatedById+,+CreatedDate+,+DelegateUser+,+Display+,+Id+,+Section+FROM+SetupAuditTrail+WHERE+CreatedDate+=+{created_date}"
    )

    audit_trails = audit_trail_object.json()

    if audit_trails["totalSize"] == 0:
        sflc_logger.info(f"Audit trail not available for {created_date}")

    else:
        log_records = audit_trails["records"]
        # Using a helper function to write audit logs to json file
        convert_audit_trail_to_json_files(log_records)

        # Upload to GCP storage
        upload_to_storage_bucket(google_project_id, storage_bucket)

        # Log update to Cloud logging
        sflc_logger.info(f"Audit trail for {created_date} uploaded to cloud storage")


# Get Private Key
private_key = get_private_key(GOOGLE_SECRETS_PROJECT_ID, SECRET_ID)

# Start script
if __name__ == "__main__":
    try:
        get_sf_audit_trails(
            TOKEN_ENDPOINT,
            private_key,
            CLIENT_ID,
            AUDIENCE,
            SUBJECT,
            created_date,
            GOOGLE_PROJECT_ID,
            CLOUD_STORAGE_BUCKET,
        )

    except Exception as err:
        sflc_logger.exception(f"An Error occured")
        sys.exit(1)
