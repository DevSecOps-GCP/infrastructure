# Autopilot: Google manages nodes and enforces hardening (Shielded nodes, Workload Identity,
# Dataplane V2, no privileged pods). Regional control plane across three zones.
resource "google_container_cluster" "this" {
  project             = local.project
  name                = var.cluster_name
  location            = local.region
  enable_autopilot    = true
  deletion_protection = true

  network         = local.network
  subnetwork      = local.subnet.self_link
  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = local.subnet.pods_range
    services_secondary_range_name = local.subnet.services_range
  }

  # No public endpoint: IAM-protected DNS endpoint for CI and operators,
  # private IP endpoint for clients inside the VPC.
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
  }

  control_plane_endpoints_config {
    dns_endpoint_config {
      allow_external_traffic = true
    }

    ip_endpoints_config {
      enabled = true
    }
  }

  master_authorized_networks_config {
    gcp_public_cidrs_access_enabled = false

    dynamic "cidr_blocks" {
      for_each = var.authorized_networks
      content {
        display_name = cidr_blocks.key
        cidr_block   = cidr_blocks.value
      }
    }
  }

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.nodes.email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    }
  }

  node_pool_auto_config {
    network_tags {
      tags = ["gke-${var.cluster_name}"]
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  # Application metrics are pushed to Prometheus on the ops cluster.
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]

    managed_prometheus {
      enabled = false
    }
  }

  cost_management_config {
    enabled = true
  }

  maintenance_policy {
    recurring_window {
      start_time = "2026-10-01T00:00:00Z"
      end_time   = "2026-10-01T04:00:00Z"
      recurrence = "FREQ=DAILY"
    }
  }

  depends_on = [google_project_iam_member.nodes]
}
