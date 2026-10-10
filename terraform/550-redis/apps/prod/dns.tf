# Resolvable only inside the VPC (and over the VPN).
resource "google_dns_record_set" "redis" {
  project      = local.dns_project
  managed_zone = local.internal_zone.name
  name         = "redis.${local.internal_zone.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_redis_instance.this.host]
}
