## Terraform IAM Module

 - Creates three different Service Accounts for the SFELC Cloud Run Instance, SFATC Cloud Run Instance and the Cloud Scheduler

 - Assigns the following IAM roles to the Service Accounts:

    - SFELC and SFATC Service Accounts:
        - roles/storage.objectCreator
        - roles/storage.legacyBucketReader
        - roles/logging.logWriter
        - roles/artifactregistry.reader
        - roles/secretmanager.secretAccessor

    - Cloud Scheduler Service Account
        - roles/run.invoker (to invoke/trigger the Cloud Run Instances)

 - Exposes the Service Account Email addresses in the 'outputs.tf' for consumption by the Cloud Run instances and Cloud Scheduler defined in the serverless module.