# Project and location Variables
variable "project_id" {
    type = string
    description = "ID of Google Project"
}

variable "secrets_project_id" {
    type = string
    description = "Project the private key secret resides"
}

variable "region" {
    type = string
    description = "Default Region"
    default = "northamerica-northeast1"
}

variable "zone" {
    type = string
    description = "Default Zone"
    default = "northamerica-northeast1-a"
}

# VPC variable
variable "ip_cidr_range" {
    type = string
    description = "IP CIDR Range for VPC Connector"
    default = "192.168.1.0/28"
}

# Cloud Storage Variables
variable "cloud_storage_bucket" {
    type = string
    description = "Cloud Storage Bucket Name"
}

variable "storage_class" {
    type = string
    description = "Storage Class Tier / Class"
    default = "STANDARD"
}

# Secret Variable
variable "secret_id" {
    type = string
    description = "Secret Id of Private Key"
}

# Cloud Run Related Variables
variable "env" {
    type = map(string)
    description = "enviromental variables for containers"
}

variable "repo_name" {
    type = string
    description = "Repository for docker images"
}

