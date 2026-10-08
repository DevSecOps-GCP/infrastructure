locals {
  service_projects = toset(["ops", "prod"])

  gke_agents = {
    for p in local.service_projects :
    p => "serviceAccount:service-${local.project_numbers[p]}@container-engine-robot.iam.gserviceaccount.com"
  }

  # Each service project may only use its own subnet.
  subnet_users = merge([
    for p in local.service_projects : {
      "${p}/gke"           = { subnet = p, member = local.gke_agents[p] }
      "${p}/cloudservices" = { subnet = p, member = "serviceAccount:${local.project_numbers[p]}@cloudservices.gserviceaccount.com" }
    }
  ]...)

  # Lets GKE in the service projects manage its firewall rules in the host project.
  host_roles = {
    for pair in setproduct(local.service_projects, ["roles/container.hostServiceAgentUser", "roles/compute.securityAdmin"]) :
    "${pair[0]}/${pair[1]}" => { project = pair[0], role = pair[1] }
  }
}

resource "google_compute_subnetwork_iam_member" "network_user" {
  for_each = local.subnet_users

  project    = local.host_project
  region     = local.region
  subnetwork = google_compute_subnetwork.this[each.value.subnet].name
  role       = "roles/compute.networkUser"
  member     = each.value.member
}

resource "google_project_iam_member" "gke_host" {
  for_each = local.host_roles

  project = local.host_project
  role    = each.value.role
  member  = local.gke_agents[each.value.project]
}
