# Enable the Artifact Registry API
resource "google_project_service" "artifact_registry" {
    project = var.project_id
    service = "artifactregistry.googleapis.com"

    timeouts {
        create = "30m"
        update = "40m"
    }

    disable_on_destroy = true
}

# Create Google Artifact Registry Repository for container images
resource "google_artifact_registry_repository" "repo" {
    location = var.region
    repository_id = var.repo_name
    description = "docker repository for log collectors images"
    format = "DOCKER"

    depends_on = [google_project_service.artifact_registry]
}

# Create Storage Bucket
resource "google_storage_bucket" "sf_log_bucket" {
    name = var.cloud_storage_bucket
    location = var.region
    force_destroy = true
    project = var.project_id
    storage_class = var.storage_class
    uniform_bucket_level_access = true
}