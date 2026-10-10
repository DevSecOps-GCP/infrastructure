# Cache only: the app falls back to Postgres when Redis is unavailable, so the Basic tier
# (single node, no replica) is enough.
resource "google_redis_instance" "this" {
  project        = local.project
  region         = local.region
  name           = var.instance_name
  display_name   = "LearnHub cache"
  tier           = "BASIC"
  memory_size_gb = var.memory_size_gb
  redis_version  = "REDIS_7_2"

  # Private IP from the Shared VPC's private services range; no public access.
  authorized_network = local.network
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  reserved_ip_range  = local.private_services_range

  # Clients send the AUTH string over TLS, verifying the server against its CA.
  auth_enabled            = true
  transit_encryption_mode = "SERVER_AUTHENTICATION"

  maintenance_policy {
    weekly_maintenance_window {
      day = "SUNDAY"

      start_time {
        hours = 0
      }
    }
  }
}
