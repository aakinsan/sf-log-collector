# Enable the Cloud Run API
resource "google_project_service" "cloud_run" {
    project = var.project_id
    service = "run.googleapis.com"

    timeouts {
        create = "30m"
        update = "40m"
    }

    disable_on_destroy = true
}

# Create the Salesforce Event Log Collector Cloud Run Job
resource "google_cloud_run_v2_job" "sfelc" {
  name     = "sfelc-job"
  location = var.region
  project = var.project_id

  template {
    template{
      containers {
        image = var.sfelc_docker_image
        dynamic "env" {
          for_each = var.env
          
          content {
            name = env.key
            value = env.value
          }
        }
      }
      vpc_access{
        connector = var.vpc_access_connector_id
        egress = "ALL_TRAFFIC"
      }
      service_account = var.sfelc_service_account
    }
  }
  depends_on = [google_project_service.cloud_run]
}

# Create the Salesforce Audit Trail Collector Cloud Run Job
resource "google_cloud_run_v2_job" "sfatc" {
  name     = "sfatc-job"
  location = var.region
  project = var.project_id

  template {
    template{
      containers {
        image = var.sfatc_docker_image
        dynamic "env" {
          for_each = var.env

          content {
            name = env.key
            value = env.value
          }
        }
      }
      vpc_access{
        connector = var.vpc_access_connector_id
        egress = "ALL_TRAFFIC"
      }
      service_account = var.sfatc_service_account
    }
  }
  depends_on = [google_project_service.cloud_run]
}

# Enable the Cloud Scheduler API
resource "google_project_service" "cloud_scheduler" {
  project = var.project_id
  service = "cloudscheduler.googleapis.com"

  timeouts {
      create = "30m"
      update = "40m"
  }

  disable_on_destroy = true
}

# Create Job scheduler for event log collection
resource "google_cloud_scheduler_job" "sfelc_job_scheduler_trigger" {
  name = "sfelc-job-scheduler-trigger"
  description = "scheduling hourly event log collection"
  schedule = "0 * * * *"
  attempt_deadline = "180s"

  http_target {
    http_method = "POST"
    uri = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.sfelc.name}:run"

    oauth_token {
      service_account_email = var.scheduler_service_account
    }
  }
  depends_on = [google_project_service.cloud_scheduler]
}

# Create Job scheduler for audit trail collection
resource "google_cloud_scheduler_job" "sfatc_job_scheduler_trigger" {
  name = "sfatc-job-scheduler-trigger"
  description = "scheduling daily audit trail collection"
  schedule = "0 0 * * *"
  attempt_deadline = "180s"

  http_target {
    http_method = "POST"
    uri = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.sfatc.name}:run"

    oauth_token {
      service_account_email = var.scheduler_service_account
    }
  }
  depends_on = [google_project_service.cloud_scheduler]
}


