""" 
Module for the logger - logs messages with severity info or higher to GCP Cloud Logging 

"""

import google.cloud.logging

import logging

# Instantiates a Google Cloud Logging Client
client = google.cloud.logging.Client()

# Retrieves a Cloud Logging handler
client.setup_logging()

# Use Python’s standard logging library to send logs to GCP
sflc_logger = logging.getLogger('sflc')

# Set minimum level of logger to info
sflc_logger.setLevel(logging.INFO)