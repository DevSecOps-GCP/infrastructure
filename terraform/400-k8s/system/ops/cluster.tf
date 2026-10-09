resource "google_container_cluster" "this" {
  project             = local.project
  name                = var.cluster_name
  location            = local.zone
  deletion_protection = true

  remove_default_node_pool = true
  initial_node_count       = 1

  network           = local.network
  subnetwork        = local.subnet.self_link
  networking_mode   = "VPC_NATIVE"
  datapath_provider = "ADVANCED_DATAPATH"

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

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${local.project}.svc.id.goog"
  }

  enable_shielded_nodes = true

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

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

  # Applies only to the temporary default pool, which is removed right after creation.
  node_config {
    machine_type    = "e2-small"
    disk_size_gb    = 30
    disk_type       = "pd-standard"
    service_account = google_service_account.nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  lifecycle {
    ignore_changes = [node_config]
  }

  depends_on = [google_project_iam_member.nodes]
}
