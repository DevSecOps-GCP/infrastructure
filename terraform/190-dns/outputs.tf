output "zone_name" {
  value = google_dns_managed_zone.public.name
}

output "dns_name" {
  value = google_dns_managed_zone.public.dns_name
}

output "name_servers" {
  description = "Set these at the registrar (OVH)"
  value       = google_dns_managed_zone.public.name_servers
}

output "ds_record" {
  description = "Add at the registrar only after the name servers have propagated"
  value       = data.google_dns_keys.public.key_signing_keys[0].ds_record
}
