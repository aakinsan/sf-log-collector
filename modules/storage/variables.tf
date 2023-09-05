variable "project_id" {
    type = string
    description = "Google Project Id"
}

variable "region" {
    type = string
    description = "Default Region"
}

variable "cloud_storage_bucket" {
    type = string
    description = "Cloud Storage Bucket Name"
}

variable "storage_class" {
    type = string
    description = "Storage Class Tier / Class"
}

variable "repo_name" {
    type = string
    description = "Repository for log docker images"
}
