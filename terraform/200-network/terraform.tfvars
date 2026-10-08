network_name = "devsecopsglobal-vpc"

subnets = {
  ops  = { cidr = "10.10.0.0/24", pods = "10.20.0.0/16", services = "10.30.0.0/20" }
  prod = { cidr = "10.10.1.0/24", pods = "10.21.0.0/16", services = "10.31.0.0/20" }
}

private_services_range = "10.50.0.0/20"
internal_domain        = "internal.devsecopsglobal.tech"
