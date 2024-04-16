"""
Module to to help with all file related operations such as file conversion, writing, deleting etc.

"""

from datetime import datetime
import pandas as pd
import json
from pathlib import Path
from google.cloud.storage import Blob
from google.cloud import storage
from google.cloud.storage import Bucket


def get_latest_log_file_url(data: dict) -> str:
    # Gets the URL to the latest log file generated for an event type by finding the index of the file record with the latest time
    # 'data' is the EventLogFile object containing records for all log files available for download
    # Timestamp format in 'data['records'][index]['LogDate']' is '2023-07-25T17:00:00.000+0000'

    # Get the number of log files available for download
    number_of_log_files = data["totalSize"]

    # Define datetime format used by salesforce to datetime.strptime method
    format_string = "%Y-%m-%dT%H:%M:%S"

    # Generate a list of all the timestamp record in the format 'YY-mm-ddTHH:MM:SS'
    # Remove the timezone info '.000+0000' in the timestamp entry using the 'split' method
    timestamp_list = [
        datetime.strptime(data["records"][i]["LogDate"].split(".")[0], format_string)
        for i in range(0, number_of_log_files)
    ]

    # Determine latest timestamp in the list using the max function
    latest_timestamp = max(timestamp_list)

    # Determine index of the maximum timestamp in generated list
    latest_timestamp_index = timestamp_list.index(latest_timestamp)

    # Use timestamp index to determine latest log file generated
    path_to_latest_log_file = data["records"][latest_timestamp_index]["LogFile"]

    # Returns path to the latest log file
    return path_to_latest_log_file


"""
def convert_csv_file_to_json(csv_file_name: str, downloaded_file: bytes) -> None:
    # Latest Log file in csv format downloaded from salesforce is converted to json
    with open(csv_file_name, "wb") as file:
        file.write(downloaded_file)
    csv_file = pd.read_csv(csv_file_name)
    csv_file.to_json(csv_file_name.split(".")[0] + ".json", orient="records")


def convert_audit_to_json(data: dict) -> None:
    # Audit Trail Logs retrieved from Salesforce is converted to json
    with open("audit_trail.json", "w") as file:
        json.dump(data, file)
"""


def convert_audit_trail_to_json_files(data: list) -> None:
    # Audit Trail Logs retrieved from Salesforce is converted to JSON files.
    # Each record is written to a single JSON file.

    file_ext = 0  # Required to make each file unique.
    for record in data:
        file_ext += 1
        with open(f"Audit_Trail.{file_ext}", "w") as file:
            json.dump(record, file)


def convert_csv_file_to_json_files(csv_file_name: str, downloaded_file: bytes) -> None:
    # Each entry in the CSV Log file downloaded from salesforce is converted to a json file

    # Write raw data in CSV format to CSV file.
    with open(csv_file_name, "wb") as file:
        file.write(downloaded_file)
    csv_file = pd.read_csv(csv_file_name)

    # Convert csv file to python object.
    records = csv_file.to_dict(orient="records")

    # Delete CSV file.
    Path(csv_file_name).unlink()

    # Write each event to a JSON file.
    file_ext = 0  # Required to make each file unique
    for record in records:
        file_ext += 1
        with open(f"{csv_file_name}.{file_ext}", "w") as file:
            json.dump(record, file)


def upload_to_storage_bucket(google_project_id: str, storage_bucket: str) -> None:
    # Uploads all Log files to the cloud storage bucket
    storage_client = storage.Client(project=google_project_id)
    log_storage_bucket = storage_client.get_bucket(storage_bucket)
    write_to_bucket_blobs(log_storage_bucket)


def write_to_bucket_blobs(storage_bucket: Bucket) -> None:
    # Generated JSON files are uploaded to a Cloud Storage folder
    # Filename format in Cloud Storage will be 'YY-mm-ddTHH:MM:SSZ-logfile.json'
    current_working_dir = Path.cwd()
    json_files = current_working_dir.glob("*.json")
    date_time_format = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")

    for json_file in json_files:
        folder_name = json_file.stem
        blob_path = f"{folder_name}/{date_time_format}-logfile.json"
        blob = Blob(blob_path, storage_bucket)
        with open(json_file, "rb") as file:
            blob.upload_from_file(file)
