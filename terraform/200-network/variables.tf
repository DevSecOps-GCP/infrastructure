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

variable "internal_domain" {
  type = string
}
