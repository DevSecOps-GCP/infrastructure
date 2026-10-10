variable "region" {
  description = "Where subnets, NAT and every regional workload live"
  type        = string
}

variable "network_name" {
  type = string
}

variable "subnets" {
  description = "One subnet per GKE cluster, keyed by service project; pods and services are secondary ranges"
  type = map(object({
    cidr     = string
    pods     = string
    services = string
  }))
}

variable "private_services_range" {
  description = "Range peered with Google services (Cloud SQL, Memorystore)"
  type        = string
}

variable "vpn_range" {
  description = "Subnet for the WireGuard VPN server"
  type        = string
}

variable "proxy_only_range" {
  description = "Proxy-only subnet used by regional internal Application Load Balancers"
  type        = string
}

variable "internal_domain" {
  type = string
}
