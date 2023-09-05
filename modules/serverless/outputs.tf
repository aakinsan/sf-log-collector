output "sfelc_job" {
    value = google_cloud_run_v2_job.sfelc.name
    description = "Event Log Collector Job"
}

output "sfatc_job" {
    value = google_cloud_run_v2_job.sfatc.name
    description = "Audit Trail Collector Job"
}