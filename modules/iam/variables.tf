variable "project_id" {
    type = string
    description = "Google Project ID"
}

variable "secrets_project_id" {
    type = string
    description = "Google Project where the private key secret resides"
}

variable "region" {
    type = string
    description = "Geographical Region"
}

variable "secret_id" {
    type = string
    description = "Secret Id of Private Key"
}

variable "cloud_storage_bucket" {
    type = string
    description = "Cloud Storage Bucket Name"
}

variable "repo_location" {
    type = string
    description = "Artifact Registry location"
}

variable "repo_name" {
    type = string
    description = "Artifact Registry name"
}

variable "sfelc_job_name" {
    type = string
    description = "Event Log Collector Job name"
}

variable "sfatc_job_name" {
    type = string
    description = "Audit Trail Collector Job name"
}