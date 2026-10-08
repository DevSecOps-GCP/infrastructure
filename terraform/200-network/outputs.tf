output "region" {
  value = var.region
}

output "network_id" {
  value = google_compute_network.this.id
}

output "network_name" {
  value = google_compute_network.this.name
}

output "subnets" {
  value = {
    for k, s in google_compute_subnetwork.this : k => {
      name           = s.name
      self_link      = s.self_link
      cidr           = s.ip_cidr_range
      pods_range     = "pods"
      services_range = "services"
    }
  }
}

output "private_services_range_name" {
  description = "allocated_ip_range for Cloud SQL / reserved_ip_range for Memorystore"
  value       = google_compute_global_address.private_services.name
}

output "internal_zone" {
  value = {
    name     = google_dns_managed_zone.internal.name
    dns_name = google_dns_managed_zone.internal.dns_name
  }
}
