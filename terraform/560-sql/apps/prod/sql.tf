resource "google_sql_database_instance" "this" {
  project             = local.project
  region              = local.region
  name                = var.instance_name
  database_version    = "POSTGRES_17"
  deletion_protection = true

  settings {
    edition                     = "ENTERPRISE"
    tier                        = var.tier
    availability_type           = "ZONAL"
    disk_type                   = "PD_SSD"
    disk_size                   = 10
    disk_autoresize             = true
    disk_autoresize_limit       = 20
    deletion_protection_enabled = true

    # Private IP from the Shared VPC's private services range only; clients must use TLS.
    ip_configuration {
      ipv4_enabled       = false
      private_network    = local.network
      allocated_ip_range = local.private_services_range
      ssl_mode           = "ENCRYPTED_ONLY"
      server_ca_mode     = "GOOGLE_MANAGED_INTERNAL_CA"
    }

    # Daily backups and point-in-time recovery, kept in the instance's region.
    backup_configuration {
      enabled                        = true
      location                       = local.region
      start_time                     = "01:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 7
      }
    }

    maintenance_window {
      day          = 7
      hour         = 2
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled = true
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }

    database_flags {
      name  = "log_temp_files"
      value = "0"
    }
  }
}

resource "google_sql_database" "app" {
  project  = local.project
  instance = google_sql_database_instance.this.name
  name     = var.database
}

# Copied into Vault: terraform output -raw password
resource "random_password" "app" {
  length  = 32
  special = false
}

resource "google_sql_user" "app" {
  project  = local.project
  instance = google_sql_database_instance.this.name
  name     = var.user
  password = random_password.app.result
}
