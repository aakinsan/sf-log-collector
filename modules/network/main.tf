# Create VPC Network
resource "google_compute_network" "sf-logcollector-vpc-network" {
  project = var.project_id
  name = "sf-logcollector-vpc"
  auto_create_subnetworks = false
  mtu = 1460
}

# Create subnetwork
resource "google_compute_subnetwork" "sf-logcollector-subnetwork" {
  name = "sf-logcollector-subnet"
  ip_cidr_range = var.ip_cidr_range
  region = var.region
  network = google_compute_network.sf-logcollector-vpc-network.id
  project = var.project_id
}

# Create VPC serverless connector
resource "google_vpc_access_connector" "sf-logcollector-connector" {
  name = "sf-logcollector-connector"
  subnet {
    name = google_compute_subnetwork.sf-logcollector-subnetwork.name
  }
  machine_type = "e2-micro"
  min_instances = 2
  max_instances = 3
  region = var.region
  project = var.project_id
}

# Create VPC Router
resource "google_compute_router" "sf-logcollector-router" {
  name = "sf-logcollector-router"
  region = var.region
  project = var.project_id
  network = google_compute_network.sf-logcollector-vpc-network.id
}

# Create static IP address
resource "google_compute_address" "sf-logcollector-address" {
  name = "sf-logcollector-address"
  address_type = "EXTERNAL"
  region = var.region
  project = var.project_id
}

# Create VPC Cloud NAT
resource "google_compute_router_nat" "sf-logcollector-nat" {
  name = "sf-logcollector-nat"
  router = google_compute_router.sf-logcollector-router.name
  region = var.region
  project = var.project_id

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = google_compute_address.sf-logcollector-address.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name = google_compute_subnetwork.sf-logcollector-subnetwork.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

