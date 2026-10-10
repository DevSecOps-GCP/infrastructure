resource "google_compute_address" "vpn" {
  project      = local.project
  name         = "${var.instance_name}-ip"
  region       = local.region
  address_type = "EXTERNAL"
}

# The VPN entry point needs a public IP; it is the only VM the folder's external-IP
# policy allows one, and only UDP 51820 is open to it.
#trivy:ignore:AVD-GCP-0031
resource "google_compute_instance" "wireguard" {
  project      = local.project
  name         = var.instance_name
  zone         = local.zone
  machine_type = var.machine_type
  tags         = ["wireguard"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = local.subnet.self_link

    access_config {
      nat_ip = google_compute_address.vpn.address
    }
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  service_account {
    email  = google_service_account.vm.email
    scopes = ["cloud-platform"]
  }

  # Configuration only; the server private key is generated on the VM and never leaves it.
  metadata = {
    enable-oslogin             = "TRUE"
    block-project-ssh-keys     = "TRUE"
    wg-listen-port             = tostring(var.listen_port)
    wg-tunnel-address          = var.tunnel_address
    wg-routed-cidr             = var.routed_cidr
    wg-peers                   = jsonencode(var.peers)
    serial-port-logging-enable = "TRUE"
  }

  metadata_startup_script = file("${path.module}/scripts/startup.sh")

  labels = {
    role = "vpn"
  }
}

resource "google_dns_record_set" "vpn" {
  project      = local.project
  managed_zone = local.public_zone
  name         = "vpn.${local.domain}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.vpn.address]
}
