# Define Required Providers for this module since it uses a 'docker' provider (kreuzwerker) which is outside the hashicorp namespace
terraform {
    required_providers {
        docker = {
            source  = "kreuzwerker/docker"
            version = "3.0.2"
        }   
    }
}

# Define path to application source code
locals {
    app_path = "${path.root}/apps"
    sfatc_app_path = "${path.root}/apps/sfatc"
    sfelc_app_path = "${path.root}/apps/sfelc"
}

# Build Docker Images
resource "docker_image" "sfelc_image" {
    name = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repo_name}/sfelc:latest"
    build {
        context = local.app_path
        dockerfile = "./sfelc/Dockerfile"
        label = {
            app: "sfelc"
            component: "event_log_collector"
        }
    }
    triggers = {
        dir_sfelc = sha1(join("", [for f in fileset(local.sfelc_app_path, "*"):filesha1("${local.sfelc_app_path}/${f}")]))
    }
}

resource "docker_image" "sfatc_image" {
    name = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repo_name}/sfatc:latest"
    build {
        context = local.app_path
        dockerfile = "./sfatc/Dockerfile"
        label = {
            app: "sfatc"
            component: "audit_trail_collector"
        }
    }
    triggers = {
        dir_sfatc = sha1(join("", [for f in fileset(local.sfatc_app_path, "*"):filesha1("${local.sfatc_app_path}/${f}")]))
    }
}

# Push Images to Artifact Registry
resource "docker_registry_image" "sfelc" {
    name = docker_image.sfelc_image.name
    keep_remotely = true
    triggers = {
        dir_sfelc = sha1(join("", [for f in fileset(local.sfelc_app_path, "*"):filesha1("${local.sfelc_app_path}/${f}")]))
    }
}

resource "docker_registry_image" "sfatc" {
    name = docker_image.sfatc_image.name
    keep_remotely = true
    triggers = {
        dir_sfatc = sha1(join("", [for f in fileset(local.sfatc_app_path, "*"):filesha1("${local.sfatc_app_path}/${f}")]))
    }
}