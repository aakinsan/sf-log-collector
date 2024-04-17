# Root Module
# Declaring Required Providers
terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "4.80.0"
        }

        docker = {
            source  = "kreuzwerker/docker"
            version = "3.0.2"
        }   
    }
}

# Google Provider
provider "google" {
    project = var.project_id
    region = var.region
    zone = var.zone
}

# Docker Provider
provider "docker" {
    host = "unix:///var/run/docker.sock"
    registry_auth {
        address = "${var.region}-docker.pkg.dev"
        username = "oauth2accesstoken"
        password = "${data.google_client_config.default.access_token}"
    }
}

# Reading this data provider results in Terraform persisting the access token (used by terraform to authenticate against the Google Cloud API) in its state file
# This token is required by the docker provider to authenticate to the Artifact Registry when pushing the docker image
# Proper precautions should be taken to protect the state file.
data "google_client_config" "default" {
}

# Module to build and push docker images
module "docker" {
    source = "./modules/docker"
    project_id = var.project_id
    region = var.region
    repo_name = module.storage.repository_name
}

# Module for IAM permissions for the Service Accounts
module "iam" {
    source = "./modules/iam"
    project_id = var.project_id
    secrets_project_id = var.secrets_project_id
    region = var.region
    secret_id = var.secret_id
    cloud_storage_bucket = module.storage.storage_bucket_name
    repo_name = module.storage.repository_name
    repo_location = module.storage.repository_location
    sfelc_job_name = module.serverless.sfelc_job
    sfatc_job_name = module.serverless.sfatc_job  
}

# Module for Network Connections
module "network" {
    source = "./modules/network"
    project_id = var.project_id
    region = var.region
    ip_cidr_range = var.ip_cidr_range 
}

# Module for the Cloud Run Instances and Cloud Scheduler
module "serverless" {
    source = "./modules/serverless"
    project_id = var.project_id
    region = var.region
    sfelc_docker_image = module.docker.sfelc_docker_image
    sfatc_docker_image = module.docker.sfatc_docker_image
    sfelc_service_account = module.iam.sfelc_service_account
    sfatc_service_account = module.iam.sfatc_service_account
    scheduler_service_account = module.iam.scheduler_service_account
    env = var.env
    repo_name = module.storage.repository_name
    vpc_access_connector_id = module.network.vpc_access_connector_id


    depends_on = [ module.storage ]
}

# Module for the Cloud Storage Bucket and Artifact Registry
module "storage" {
    source = "./modules/storage"  
    project_id = var.project_id
    region = var.region
    cloud_storage_bucket = var.cloud_storage_bucket
    storage_class = var.storage_class
    repo_name = var.repo_name
}

