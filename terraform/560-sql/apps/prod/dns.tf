# Resolvable only inside the VPC (and over the VPN).
resource "google_dns_record_set" "postgres" {
  project      = local.dns_project
  managed_zone = local.internal_zone.name
  name         = "postgres.${local.internal_zone.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_sql_database_instance.this.private_ip_address]
}
