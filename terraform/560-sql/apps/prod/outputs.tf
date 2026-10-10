output "postgres" {
  value = {
    connection_name = google_sql_database_instance.this.connection_name
    host            = google_sql_database_instance.this.private_ip_address
    port            = 5432
    hostname        = trimsuffix(google_dns_record_set.postgres.name, ".")
    database        = google_sql_database.app.name
    user            = google_sql_user.app.name
  }
}

# CA that signs the instance's server certificate (DB_SSL=verify-ca). A CA certificate is
# public; the provider marks the whole server_ca_cert block sensitive.
output "server_ca_cert" {
  value = nonsensitive(google_sql_database_instance.this.server_ca_cert[0].cert)
}

output "password" {
  value     = random_password.app.result
  sensitive = true
}
