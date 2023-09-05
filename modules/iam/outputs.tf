output "sfelc_service_account" {
    value = google_service_account.sfelc.email
    description = "sfelc Cloud Run Aervice Account"
}

output "sfatc_service_account" {
    value = google_service_account.sfatc.email
    description = "sfatc Cloud Run Service Account"
}

output "scheduler_service_account" {
    value = google_service_account.job_scheduler.email
    description = "Cloud Scheduler Service Account"
}