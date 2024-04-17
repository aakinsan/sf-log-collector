output "vpc_access_connector_id" {
    value = google_vpc_access_connector.sf-logcollector-connector.id
    description = "VPC Access Connector"
}