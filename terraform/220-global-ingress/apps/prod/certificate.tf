# Google-managed certificate validated through DNS, so it is issued before the load
# balancer serves traffic. The Gateway selects it through the certificate map.
resource "google_certificate_manager_dns_authorization" "app" {
  project = local.project
  name    = "app"
  domain  = local.fqdn
}

resource "google_dns_record_set" "app_dns_authorization" {
  project      = local.dns_project
  managed_zone = local.public_zone
  name         = google_certificate_manager_dns_authorization.app.dns_resource_record[0].name
  type         = google_certificate_manager_dns_authorization.app.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.app.dns_resource_record[0].data]
}

resource "google_certificate_manager_certificate" "app" {
  project = local.project
  name    = "app"

  managed {
    domains            = [local.fqdn]
    dns_authorizations = [google_certificate_manager_dns_authorization.app.id]
  }
}

resource "google_certificate_manager_certificate_map" "app" {
  project = local.project
  name    = "app"
}

resource "google_certificate_manager_certificate_map_entry" "app" {
  project      = local.project
  name         = "app"
  map          = google_certificate_manager_certificate_map.app.name
  hostname     = local.fqdn
  certificates = [google_certificate_manager_certificate.app.id]
}
