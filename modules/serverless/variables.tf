variable "project_id" {
    type = string
    description = "Google Project Id"
}

variable "region" {
    type = string
    description = "Default Region"
}

variable "repo_name" {
    type = string
    description = "Repository for log docker images"
}

variable "sfelc_docker_image" {
    type = string
    description = "sfelc docker image name"
}

variable "sfatc_docker_image" {
    type = string
    description = "sfatc docker image name"
}

variable "sfelc_service_account" {
    type = string
    description = "sfelc cloud run service account"
}

variable "sfatc_service_account" {
    type = string
    description = "sfatc cloud run service account"
}

variable "scheduler_service_account" {
    type = string
    description = "Cloud Scheduler Service Account"
}

variable "env" {
    type = map(string)
    description = "Enviromental Variables for containers"
}

