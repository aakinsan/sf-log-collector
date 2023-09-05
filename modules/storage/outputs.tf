output "storage_bucket_name" {
    value = google_storage_bucket.sf_log_bucket.name
    description = "Cloud storage Bucket name"
}

output "repository_location" {
    value = google_artifact_registry_repository.repo.location
    description = "Artifact Registry location"
}

output "repository_name" {
    value = google_artifact_registry_repository.repo.name
    description = "Artifact Registry name"
}