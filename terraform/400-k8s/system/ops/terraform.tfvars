cluster_name = "ops"
zone_suffix  = "a"
machine_type = "e2-standard-2"
min_nodes    = 2
max_nodes    = 3

authorized_networks = {
  "node-subnets" = "10.10.0.0/16"
  "pods"         = "10.20.0.0/15"
}
