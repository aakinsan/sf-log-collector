# Create Cloud Run service accounts
resource "google_service_account" "sfelc" {
    account_id = "sfelc-sa"
    display_name = "sfelc"
    description = "Salesforce Event Log Collector Service Account"
    project = var.project_id
}

resource "google_service_account" "sfatc" {
    account_id = "sfatc-sa"
    display_name = "sfatc"
    description = "Salesforce Audit Trail Collector Service Account"
    project = var.project_id
}

# Create Cloud Scheduler service account
resource "google_service_account" "job_scheduler" {
    account_id = "scheduler-sa"
    display_name = "job scheduler"
    description = "Job Scheduler for log and audit trail collection"
    project = var.project_id
}

locals {
    cloud_run_service_accounts = [
        "serviceAccount:${google_service_account.sfelc.email}", 
        "serviceAccount:${google_service_account.sfatc.email}"
    ]
}
# Assign Cloud Storage IAM roles
resource "google_storage_bucket_iam_member" "storage_object_creator_role" {
    for_each = {for indx, val in local.cloud_run_service_accounts: indx => val}
    bucket = var.cloud_storage_bucket
    role = "roles/storage.objectCreator"
    member = each.value
}

resource "google_storage_bucket_iam_member" "storage_legacy_bucket_reader_role" {
    for_each = {for indx, val in local.cloud_run_service_accounts: indx => val}
    bucket = var.cloud_storage_bucket
    role = "roles/storage.legacyBucketReader"
    member = each.value
}

# Assign Cloud Logging IAM role
resource "google_project_iam_member" "logging_role" {
    for_each = {for k, v in local.cloud_run_service_accounts: k => v}
    project = var.project_id
    role = "roles/logging.logWriter"
    member = each.value
}

# Assign Cloud Artifact Registry IAM role
resource "google_artifact_registry_repository_iam_member" "lc_repo_role" {
    for_each = {for k, v in local.cloud_run_service_accounts: k => v}
    project = var.project_id
    location = var.repo_location
    repository = var.repo_name
    role = "roles/artifactregistry.reader"
    member = each.value
}

# Assign Secret Manager IAM role
resource "google_secret_manager_secret_iam_member" "secret_manager_role" {    
    for_each = {for k, v in local.cloud_run_service_accounts: k => v}
    project = var.secrets_project_id
    secret_id = var.secret_id
    role = "roles/secretmanager.secretAccessor"
    member  = each.value
}

# Assign Cloud run invoker role to Cloud Scheduler Service Account
# Allows Cloud Scheduler to invoke the Cloud run jobs
resource "google_cloud_run_v2_job_iam_member" "cloud_run_sfelc_role" {
    project = var.project_id
    location = var.region
    name = var.sfelc_job_name
    role = "roles/run.invoker"
    member = "serviceAccount:${google_service_account.job_scheduler.email}"
}

resource "google_cloud_run_v2_job_iam_member" "cloud_run_sfatc_role" {
    project = var.project_id
    location = var.region
    name = var.sfatc_job_name
    role = "roles/run.invoker"
    member = "serviceAccount:${google_service_account.job_scheduler.email}"
}