locals {
  project = data.terraform_remote_state.projects.outputs.project_ids["net"]
}

resource "google_dns_managed_zone" "public" {
  project     = local.project
  name        = replace(var.domain, ".", "-")
  dns_name    = "${var.domain}."
  description = "Public zone for ${var.domain}. Internal names live in a private zone."
  visibility  = "public"

  dnssec_config {
    state = "on"

    default_key_specs {
      algorithm  = "ecdsap256sha256"
      key_length = 256
      key_type   = "keySigning"
    }

    default_key_specs {
      algorithm  = "ecdsap256sha256"
      key_length = 256
      key_type   = "zoneSigning"
    }
  }
}

# Only Google (app certificate) and Let's Encrypt (internal wildcard) may issue certificates.
resource "google_dns_record_set" "caa" {
  project      = local.project
  managed_zone = google_dns_managed_zone.public.name
  name         = google_dns_managed_zone.public.dns_name
  type         = "CAA"
  ttl          = 3600
  rrdatas = [
    "0 issue \"pki.goog\"",
    "0 issue \"letsencrypt.org\"",
    "0 issuewild \"letsencrypt.org\"",
  ]
}
