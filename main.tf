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

provider "google" {
    project = var.project_id
    region = var.region
    zone = var.zone
}

provider "docker" {
    host = "unix:///var/run/docker.sock"
    registry_auth {
        address = "${var.region}-docker.pkg.dev"
        username = "oauth2accesstoken"
        password = "${data.google_client_config.default.access_token}"
    }
}

data "google_client_config" "default" {
}

module "docker" {
    source = "./modules/docker"
    project_id = var.project_id
    region = var.region
    repo_name = module.storage.repository_name
}

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

    depends_on = [ module.storage ]
}

module "storage" {
    source = "./modules/storage"  
    project_id = var.project_id
    region = var.region
    cloud_storage_bucket = var.cloud_storage_bucket
    storage_class = var.storage_class
    repo_name = var.repo_name
}

