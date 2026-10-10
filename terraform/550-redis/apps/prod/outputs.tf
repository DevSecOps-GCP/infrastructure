output "redis" {
  value = {
    host     = google_redis_instance.this.host
    port     = google_redis_instance.this.port
    hostname = trimsuffix(google_dns_record_set.redis.name, ".")
  }
}

# CA bundle clients use to verify the server; also carries the next CA once Memorystore issues it.
output "server_ca_certs" {
  value = join("", google_redis_instance.this.server_ca_certs[*].cert)
}

# Copied into Vault: terraform output -raw auth_string
output "auth_string" {
  value     = google_redis_instance.this.auth_string
  sensitive = true
}
